import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/crdt/crdt_block.dart';
import '../../../../core/crdt/crdt_document.dart';
import '../../../../core/crdt/crdt_op_event.dart';
import '../../../../core/crdt/presence_event.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/network/offline_queue.dart';
import '../../../../core/network/realtime/realtime_transport.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/collaboration_invite.dart';
import '../../domain/models/draft_model.dart';
import '../../domain/models/format_collab_policy.dart' hide collabPolicyFor;
import '../../domain/templates/template_resolver.dart';

// ── Presence State ────────────────────────────────────────────────────────────

/// The live state of a single remote collaborator in the current session.
class CollaboratorPresenceState {
  const CollaboratorPresenceState({
    required this.userId,
    required this.displayName,
    required this.role,
    required this.color,
    this.cursorOffset = 0,
    this.cursorBlockId = 'root',
    this.selectionStart,
    this.selectionEnd,
    this.isTyping = false,
    this.isOnline = true,
  });

  final String userId;
  final String displayName;
  final String role;

  /// Deterministic color from userId hash — consistent across both clients.
  final int color;

  final int cursorOffset;
  final String cursorBlockId;
  final int? selectionStart;
  final int? selectionEnd;
  final bool isTyping;
  final bool isOnline;

  CollaboratorPresenceState copyWith({
    int? cursorOffset,
    String? cursorBlockId,
    int? selectionStart,
    int? selectionEnd,
    bool? isTyping,
    bool? isOnline,
  }) =>
      CollaboratorPresenceState(
        userId: userId,
        displayName: displayName,
        role: role,
        color: color,
        cursorOffset: cursorOffset ?? this.cursorOffset,
        cursorBlockId: cursorBlockId ?? this.cursorBlockId,
        selectionStart: selectionStart ?? this.selectionStart,
        selectionEnd: selectionEnd ?? this.selectionEnd,
        isTyping: isTyping ?? this.isTyping,
        isOnline: isOnline ?? this.isOnline,
      );
}

// ── Collab Session State ──────────────────────────────────────────────────────

class CollabSessionState {
  const CollabSessionState({
    required this.draftId,
    required this.localClientId,
    required this.localRole,
    required this.policy,
    this.collaborators = const {},
    this.isConnected = false,
    this.pendingOpCount = 0,
  });

  final String draftId;
  final String localClientId;
  final CollaboratorRole localRole;
  final FormatCollabPolicy policy;

  /// Remote collaborator presence, keyed by userId.
  final Map<String, CollaboratorPresenceState> collaborators;

  final bool isConnected;

  /// Ops queued for offline replay.
  final int pendingOpCount;

  /// True for editors — all local changes become suggestions.
  bool get suggestOnly => localRole == CollaboratorRole.editor;

  CollabSessionState copyWith({
    Map<String, CollaboratorPresenceState>? collaborators,
    bool? isConnected,
    int? pendingOpCount,
  }) =>
      CollabSessionState(
        draftId: draftId,
        localClientId: localClientId,
        localRole: localRole,
        policy: policy,
        collaborators: collaborators ?? this.collaborators,
        isConnected: isConnected ?? this.isConnected,
        pendingOpCount: pendingOpCount ?? this.pendingOpCount,
      );
}

// ── Fake Realtime Channel (mock/dev seam) ─────────────────────────────────────

/// In-process fake that implements [RealtimeChannel] without a real server.
/// Produces scripted mock presence and op events so the UI is fully testable
/// without backend infrastructure. Swap for the real WebSocket channel
/// by overriding [collabPresenceChannelProvider] /
/// [collabOpChannelProvider] in production.
class _FakePresenceChannel implements RealtimeChannel<PresenceEvent> {
  final _controller = StreamController<PresenceEvent>.broadcast();
  Timer? _mockTypingTimer;
  bool _connected = false;

  @override
  Stream<PresenceEvent> get events => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async {
    _connected = true;
    // Simulate a collaborator joining 800ms after session starts.
    await Future.delayed(const Duration(milliseconds: 800));
    _controller.add(CollaboratorJoinedEvent(
      draftId: 'mock_draft',
      userId: 'mock_collab_user',
      displayName: 'Maya Osei',
      role: 'coAuthor',
    ));
    // Then simulate them starting to type after a further 2s.
    _mockTypingTimer = Timer(const Duration(seconds: 2), () {
      _controller.add(TypingStartedEvent(
        draftId: 'mock_draft',
        userId: 'mock_collab_user',
        displayName: 'Maya Osei',
      ));
      _controller.add(CursorMovedEvent(
        draftId: 'mock_draft',
        userId: 'mock_collab_user',
        displayName: 'Maya Osei',
        offset: 12,
        blockId: 'root',
      ));
      // Stop typing after 3s.
      Timer(const Duration(seconds: 3), () {
        if (!_controller.isClosed) {
          _controller.add(TypingStoppedEvent(
            draftId: 'mock_draft',
            userId: 'mock_collab_user',
          ));
        }
      });
    });
  }

  @override
  Future<void> disconnect() async {
    _mockTypingTimer?.cancel();
    _connected = false;
    if (!_controller.isClosed) {
      _controller.add(CollaboratorLeftEvent(
        draftId: 'mock_draft',
        userId: 'mock_collab_user',
      ));
    }
  }

  @override
  void send(PresenceEvent event) {
    // In mock mode: echo back to ourselves so the UI sees its own events.
    // In production this would be sent over the WebSocket to all peers.
    _controller.add(event);
  }
}

class _FakeOpChannel implements RealtimeChannel<CrdtOpEvent> {
  final _controller = StreamController<CrdtOpEvent>.broadcast();
  bool _connected = false;

  @override
  Stream<CrdtOpEvent> get events => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  Future<void> connect() async => _connected = true;

  @override
  Future<void> disconnect() async => _connected = false;

  @override
  void send(CrdtOpEvent event) {
    // Echo: in mock mode the only collaborator is simulated, so we don't
    // need to process inbound ops — the CRDT document is local-only.
    _controller.add(event);
  }
}

// ── CollabSyncService ─────────────────────────────────────────────────────────

/// Owns all real-time collaboration state for one open draft session.
///
/// Responsibilities:
/// - Maintains a [CrdtDocument] per block (or 'root' for flat docs).
/// - Sends local edits as [CrdtOpEvent]s; merges incoming remote ops.
/// - Manages presence (cursor, typing) via [PresenceEvent]s.
/// - Queues offline ops in [OfflineQueue] and replays on reconnect.
/// - Enforces role permissions (centralized here — not duplicated per format).
class CollabSyncService extends StateNotifier<CollabSessionState> {
  CollabSyncService({
    required Ref ref,
    required DraftModel draft,
  })  : _ref = ref,
        _draft = draft,
        super(_buildInitialState(ref, draft)) {
    _doc = CrdtDocument(
      clientId: state.localClientId,
      initialText: draft.body,
    );
    _presenceChannel = _FakePresenceChannel();
    _opChannel = _FakeOpChannel();
    _registerOutboxHandler();
  }

  final Ref _ref;
  DraftModel _draft;
  late CrdtDocument _doc;
  late RealtimeChannel<PresenceEvent> _presenceChannel;
  late RealtimeChannel<CrdtOpEvent> _opChannel;

  StreamSubscription<PresenceEvent>? _presenceSub;
  StreamSubscription<CrdtOpEvent>? _opSub;
  StreamSubscription<bool>? _connectivitySub;
  Timer? _typingStopTimer;
  Timer? _simTimer;
  bool _isTyping = false;
  bool _isSimulating = false;

  static CollabSessionState _buildInitialState(Ref ref, DraftModel draft) {
    final authState = ref.read(authControllerProvider);
    final userId = authState.user?.id ?? 'local_user';
    final policy = collabPolicyFor(draft.type);

    // Determine the local user's role for this draft.
    CollaboratorRole role = CollaboratorRole.coAuthor; // owner
    final invite = draft.collaborators.where(
      (c) => c.inviteeUserId == userId && c.status == InviteStatus.accepted,
    ).firstOrNull;
    if (invite != null) role = invite.role;

    return CollabSessionState(
      draftId: draft.id,
      localClientId: userId,
      localRole: role,
      policy: policy,
    );
  }

  // ── Role enforcement ─────────────────────────────────────────────────────────

  void _requireRole(Set<CollaboratorRole> allowed) {
    if (!allowed.contains(state.localRole) &&
        state.localRole != CollaboratorRole.coAuthor) {
      throw const CollaborationException("You don't have permission for this action.");
    }
  }

  // ── Session lifecycle ────────────────────────────────────────────────────────

  Future<void> connect() async {
    if (state.isConnected) return;

    await _presenceChannel.connect();
    await _opChannel.connect();

    _presenceSub = _presenceChannel.events.listen(_handlePresenceEvent);
    _opSub = _opChannel.events.listen(_handleOpEvent);

    _connectivitySub = _ref.read(connectivityServiceProvider).onStatusChange.listen((online) {
      if (online && !state.isConnected) {
        connect();
        _flushOfflineOps();
      } else if (!online) {
        state = state.copyWith(isConnected: false);
      }
    });

    state = state.copyWith(isConnected: true);

    // Announce presence.
    _presenceChannel.send(CollaboratorJoinedEvent(
      draftId: state.draftId,
      userId: state.localClientId,
      displayName: _ref.read(authControllerProvider).user?.displayName ?? 'You',
      role: state.localRole.name,
    ));
  }

  Future<void> disconnect() async {
    _presenceChannel.send(CollaboratorLeftEvent(
      draftId: state.draftId,
      userId: state.localClientId,
    ));
    await _presenceChannel.disconnect();
    await _opChannel.disconnect();
    _presenceSub?.cancel();
    _opSub?.cancel();
    _connectivitySub?.cancel();
    _typingStopTimer?.cancel();
    state = state.copyWith(isConnected: false);
  }

  // ── Local edit API ───────────────────────────────────────────────────────────

  /// Called when the user types into the editor. Applies the op locally via
  /// the CRDT document and broadcasts to peers. Editor-role users produce
  /// [SuggestOp]s instead of [InsertOp]s.
  String localInsert(String text, int atIndex, {String blockId = 'root'}) {
    _requireRole({CollaboratorRole.coAuthor, CollaboratorRole.editor});
    _onTypingActivity();

    final CrdtOp op;
    if (state.suggestOnly) {
      op = _doc.localSuggest(text, atIndex, blockId: blockId);
    } else {
      op = _doc.localInsert(text, atIndex, blockId: blockId);
    }
    _broadcastOp(op, blockId);
    return _doc.resolveText(blockId: blockId);
  }

  String localDelete(int atIndex, int length, {String blockId = 'root'}) {
    _requireRole({CollaboratorRole.coAuthor});
    _onTypingActivity();

    final op = _doc.localDelete(atIndex, length, blockId: blockId);
    _broadcastOp(op, blockId);
    return _doc.resolveText(blockId: blockId);
  }

  /// Accept a pending suggestion by op id (coAuthor / owner only).
  void acceptSuggestion(String opId) {
    _requireRole({CollaboratorRole.coAuthor});
    _doc.acceptSuggestion(opId);
    // Broadcast the accepted state so the editor-peer sees it resolved.
    final accepted = _doc.ops.whereType<SuggestOp>()
        .where((op) => op.id == opId && op.accepted == true)
        .firstOrNull;
    if (accepted != null) _broadcastOp(accepted, accepted.blockId);
  }

  /// Reject a pending suggestion.
  void rejectSuggestion(String opId) {
    _requireRole({CollaboratorRole.coAuthor});
    _doc.rejectSuggestion(opId);
    final rejected = _doc.ops.whereType<SuggestOp>()
        .where((op) => op.id == opId && op.accepted == false)
        .firstOrNull;
    if (rejected != null) _broadcastOp(rejected, rejected.blockId);
  }

  /// Current resolved text for a block (or 'root' for flat docs).
  String resolvedText({String blockId = 'root'}) =>
      _doc.resolveText(blockId: blockId);

  /// Pending suggestions the coAuthor needs to review.
  List<SuggestOp> get pendingSuggestions => _doc.pendingSuggestions;

  // ── Cursor / presence ────────────────────────────────────────────────────────

  void reportCursorMoved(int offset, {String blockId = 'root'}) {
    if (!state.isConnected) return;
    _presenceChannel.send(CursorMovedEvent(
      draftId: state.draftId,
      userId: state.localClientId,
      displayName: _ref.read(authControllerProvider).user?.displayName ?? 'You',
      offset: offset,
      blockId: blockId,
    ));
  }

  void reportSelectionChanged(int start, int end, {String blockId = 'root'}) {
    if (!state.isConnected) return;
    _presenceChannel.send(SelectionChangedEvent(
      draftId: state.draftId,
      userId: state.localClientId,
      displayName: _ref.read(authControllerProvider).user?.displayName ?? 'You',
      start: start,
      end: end,
      blockId: blockId,
    ));
  }

  // ── Private: event handlers ───────────────────────────────────────────────────

  void _handlePresenceEvent(PresenceEvent event) {
    if (!mounted) return;
    // Ignore our own echoed events.
    if (event.userId == state.localClientId) return;

    final collaborators = Map<String, CollaboratorPresenceState>.from(state.collaborators);

    switch (event) {
      case CollaboratorJoinedEvent(:final userId, :final displayName, :final role):
        collaborators[userId] = CollaboratorPresenceState(
          userId: userId,
          displayName: displayName,
          role: role,
          color: _colorForUser(userId),
        );

      case CollaboratorLeftEvent(:final userId):
        collaborators.remove(userId);

      case CursorMovedEvent(:final userId, :final displayName, :final offset, :final blockId):
        final existing = collaborators[userId];
        collaborators[userId] = (existing ?? CollaboratorPresenceState(
          userId: userId,
          displayName: displayName,
          role: 'coAuthor',
          color: _colorForUser(userId),
        )).copyWith(cursorOffset: offset, cursorBlockId: blockId);

      case SelectionChangedEvent(:final userId, :final start, :final end):
        collaborators[userId] = collaborators[userId]?.copyWith(
          selectionStart: start,
          selectionEnd: end,
        ) ?? CollaboratorPresenceState(
          userId: userId,
          displayName: '',
          role: 'coAuthor',
          color: _colorForUser(userId),
          selectionStart: start,
          selectionEnd: end,
        );

      case TypingStartedEvent(:final userId):
        collaborators[userId] = collaborators[userId]?.copyWith(isTyping: true)
            ?? CollaboratorPresenceState(
                userId: userId,
                displayName: '',
                role: 'coAuthor',
                color: _colorForUser(userId),
                isTyping: true,
              );

      case TypingStoppedEvent(:final userId):
        collaborators[userId] = collaborators[userId]?.copyWith(isTyping: false)
            ?? CollaboratorPresenceState(
                userId: userId,
                displayName: '',
                role: 'coAuthor',
                color: _colorForUser(userId),
              );
    }

    state = state.copyWith(collaborators: collaborators);
  }

  void _handleOpEvent(CrdtOpEvent event) {
    if (!mounted) return;
    // Ignore our own echoed ops (already applied locally).
    if (event.clientId == state.localClientId) return;
    _doc.merge(event.ops);
    // Notify listeners that the document changed.
    state = state.copyWith(); // triggers rebuild via StateNotifier equality
  }

  // ── Private: broadcasting ─────────────────────────────────────────────────────

  void _broadcastOp(CrdtOp op, String blockId) {
    final event = CrdtOpEvent(
      draftId: state.draftId,
      blockId: blockId,
      ops: [op],
      clientId: state.localClientId,
      clock: _doc.clock,
    );

    if (state.isConnected) {
      _opChannel.send(event);
    } else {
      // Queue for offline replay.
      _ref.read(offlineQueueProvider).enqueue('crdt_op_batch', event.toJson());
      state = state.copyWith(pendingOpCount: state.pendingOpCount + 1);
    }
  }

  void _registerOutboxHandler() {
    _ref.read(offlineQueueProvider).registerHandler('crdt_op_batch', (entry) async {
      try {
        final event = CrdtOpEvent.fromJson(entry.payload);
        if (!mounted) return false;
        if (event.draftId != state.draftId) return false;
        _opChannel.send(event);
        state = state.copyWith(
          pendingOpCount: (state.pendingOpCount - 1).clamp(0, 9999),
        );
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  Future<void> _flushOfflineOps() async {
    await _ref.read(offlineQueueProvider).processQueue();
  }

  // ── Private: typing debounce ──────────────────────────────────────────────────

  void _onTypingActivity() {
    if (!state.isConnected) return;
    if (!_isTyping) {
      _isTyping = true;
      _presenceChannel.send(TypingStartedEvent(
        draftId: state.draftId,
        userId: state.localClientId,
        displayName: _ref.read(authControllerProvider).user?.displayName ?? 'You',
      ));
    }
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      if (state.isConnected) {
        _presenceChannel.send(TypingStoppedEvent(
          draftId: state.draftId,
          userId: state.localClientId,
        ));
      }
    });
  }

  // ── Private: color utility ────────────────────────────────────────────────────

  /// Deterministic collaborator color from userId hash.
  /// Same algorithm on both clients → same color for same user everywhere.
  static const _palette = [
    0xFF7C6FCD, // violet
    0xFF5BA4CF, // steel blue
    0xFF60B86C, // sage green
    0xFFE8B36A, // warm amber
    0xFFE07B79, // dusty rose
    0xFF9B7EC8, // lavender
  ];

  static int _colorForUser(String userId) {
    final hash = userId.codeUnits.fold(0, (acc, c) => acc * 31 + c);
    return _palette[hash.abs() % _palette.length];
  }

  bool get isSimulating => _isSimulating;

  void startRealTimeCollabSimulation({String name = 'Maya Osei'}) {
    if (_isSimulating) return;
    _isSimulating = true;

    final collabId = 'simulated_peer_user';

    // 1. Peer Joins
    _handlePresenceEvent(CollaboratorJoinedEvent(
      draftId: state.draftId,
      userId: collabId,
      displayName: name,
      role: 'coAuthor',
    ));

    // 2. Typing start delay
    _simTimer = Timer(const Duration(milliseconds: 1000), () {
      _handlePresenceEvent(TypingStartedEvent(
        draftId: state.draftId,
        userId: collabId,
        displayName: name,
      ));

      final textToType = "\n\n*Private Journal Entry (Maya)*:\nToday was a beautiful day. We spent the afternoon sitting by the lake, watching the swans glide across the water. Writing this together makes it feel so special. 📝✨";
      int index = 0;

      _simTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        if (!_isSimulating) {
          timer.cancel();
          return;
        }

        if (index >= textToType.length) {
          timer.cancel();
          _isSimulating = false;
          _handlePresenceEvent(TypingStoppedEvent(
            draftId: state.draftId,
            userId: collabId,
          ));
          return;
        }

        final char = textToType[index];
        final currentText = _doc.resolveText(blockId: 'root');
        final currentDocLength = currentText.length;

        // Build and dispatch CrdtOpEvent containing an InsertOp
        final op = InsertOp(
          id: 'simulated_${DateTime.now().millisecondsSinceEpoch}_$index',
          clientId: collabId,
          clock: _doc.clock + 1,
          blockId: 'root',
          index: currentDocLength,
          text: char,
        );

        _handleOpEvent(CrdtOpEvent(
          draftId: state.draftId,
          blockId: 'root',
          ops: [op],
          clientId: collabId,
          clock: _doc.clock + 1,
        ));

        // Move cursor presence
        _handlePresenceEvent(CursorMovedEvent(
          draftId: state.draftId,
          userId: collabId,
          displayName: name,
          offset: currentDocLength + 1,
          blockId: 'root',
        ));

        index++;
      });
    });
  }

  void stopRealTimeCollabSimulation() {
    _isSimulating = false;
    _simTimer?.cancel();
    _simTimer = null;
    final collabId = 'simulated_peer_user';
    _handlePresenceEvent(CollaboratorLeftEvent(
      draftId: state.draftId,
      userId: collabId,
    ));
  }

  @override
  void dispose() {
    disconnect();
    _typingStopTimer?.cancel();
    _simTimer?.cancel();
    _isSimulating = false;
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Family provider: one [CollabSyncService] per draft id.
/// Auto-disposes when the create screen is closed.
final collabSyncServiceProvider = StateNotifierProvider.autoDispose
    .family<CollabSyncService, CollabSessionState, String>((ref, draftId) {
  // The create provider holds the live DraftModel; read it here.
  final draft = ref.read(draftModelForCollabProvider(draftId));
  return CollabSyncService(ref: ref, draft: draft);
});

/// Thin read-only provider for the draft's model, used by
/// [collabSyncServiceProvider] to construct a [CollabSyncService].
/// In production this would fetch from a network/cache layer;
/// for now it falls through to Hive via the drafts repository.
final draftModelForCollabProvider =
    Provider.family.autoDispose<DraftModel, String>((ref, draftId) {
  // Fallback: create a new empty draft if not found (shouldn't happen in prod).
  return DraftModel(
    id: draftId,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
});

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/widgets/pyago_badge.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../home/domain/models/post_model.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/services/collab_sync_service.dart';
import '../../domain/models/collaboration_invite.dart';
import '../../domain/models/draft_model.dart';
import '../../domain/models/format_collab_policy.dart' hide collabPolicyFor;
import '../../domain/models/media_attachment.dart';
import '../../domain/templates/post_template.dart';
import '../../domain/templates/template_resolver.dart';
import '../../data/services/media_pipeline_service.dart';
import '../providers/create_provider.dart';
import '../providers/collab_presence_provider.dart';
import '../widgets/collab_presence_bar.dart';
import '../widgets/collaborator_cursor.dart';
import '../widgets/suggestion_overlay.dart';
import '../widgets/story_chapter_list.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key, this.existingDraft});

  final DraftModel? existingDraft;

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  final _bodyFocusNode = FocusNode();
  bool _previewMode = false;
  bool _collabSessionActive = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingDraft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(createControllerProvider.notifier).loadDraft(widget.existingDraft!);
        // Auto-connect collab session if this draft has accepted collaborators.
        _maybeAutoConnect(widget.existingDraft!);
      });
    }
    final DraftModel initialDraft = widget.existingDraft ?? ref.read(createControllerProvider);
    _title = TextEditingController(text: initialDraft.title);
    _body = TextEditingController(text: initialDraft.body);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _bodyFocusNode.dispose();
    // Disconnect collab session when editor closes.
    if (_collabSessionActive) {
      final draft = ref.read(createControllerProvider);
      ref.read(collabSyncServiceProvider(draft.id).notifier).disconnect();
    }
    super.dispose();
  }

  void _maybeAutoConnect(DraftModel draft) {
    final hasAccepted = draft.collaborators.any((c) => c.status == InviteStatus.accepted);
    final policy = collabPolicyFor(draft.type);
    if (hasAccepted && policy.mode == CollabMode.realtime) {
      _connectCollabSession(draft.id);
    }
  }

  void _connectCollabSession(String draftId) {
    if (_collabSessionActive) return;
    ref.read(collabSyncServiceProvider(draftId).notifier).connect();
    setState(() => _collabSessionActive = true);
  }

  void _wrapSelection(String prefix, String suffix) {
    final selection = _body.selection;
    final text = _body.text;
    if (!selection.isValid) return;
    final start = selection.start;
    final end = selection.end;
    final newText = text.replaceRange(start, end, '$prefix${text.substring(start, end)}$suffix');
    _body.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: end + prefix.length + suffix.length),
    );
    ref.read(createControllerProvider.notifier).updateBody(newText);
  }

  String _buildGhostText(String text, List<String> hints) {
    final lines = text.split('\n');
    final ghostLines = <String>[];
    for (int i = 0; i < hints.length; i++) {
      if (i < lines.length && lines[i].isNotEmpty) {
        ghostLines.add('');
      } else {
        ghostLines.add(hints[i]);
      }
    }
    return ghostLines.join('\n');
  }

  void _insertLinePrefix(String prefix) {
    final selection = _body.selection;
    final text = _body.text;
    final lineStart = text.lastIndexOf('\n', (selection.start - 1).clamp(0, text.length)) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    _body.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.end + prefix.length),
    );
    ref.read(createControllerProvider.notifier).updateBody(newText);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createControllerProvider);
    final controller = ref.read(createControllerProvider.notifier);
    final template = templateFor(draft.type);
    final scheme = Theme.of(context).colorScheme;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sync programmatically generated text updates from collaboration
    ref.listen<DraftModel>(createControllerProvider, (previous, next) {
      if (next.body != _body.text) {
        final oldSelection = _body.selection;
        _body.value = TextEditingValue(
          text: next.body,
          selection: oldSelection.copyWith(
            baseOffset: oldSelection.baseOffset.clamp(0, next.body.length),
            extentOffset: oldSelection.extentOffset.clamp(0, next.body.length),
          ),
        );
      }
      if (next.title != _title.text) {
        final oldSelection = _title.selection;
        _title.value = TextEditingValue(
          text: next.title,
          selection: oldSelection.copyWith(
            baseOffset: oldSelection.baseOffset.clamp(0, next.title.length),
            extentOffset: oldSelection.extentOffset.clamp(0, next.title.length),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final type in PostType.values) ...[
                PyagoTag(
                  label: type.label,
                  selected: draft.type == type,
                  onTap: () {
                    try {
                      controller.updateType(type);
                    } on FormatException catch (_) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Change format?'),
                          content: const Text('This will apply a new template. Your existing text will be kept below it.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                controller.updateType(type, force: true);
                              },
                              child: const Text('Proceed'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Collaboration Settings',
            icon: const Icon(Icons.people_alt_rounded),
            onPressed: () => _showSharingSettingsSheet(context, draft, controller),
          ),
          IconButton(
            tooltip: _previewMode ? 'Edit' : 'Preview',
            icon: Icon(_previewMode ? Icons.edit_outlined : Icons.visibility_outlined),
            onPressed: () => setState(() => _previewMode = !_previewMode),
          ),
          TextButton(
            onPressed: draft.isEmpty
                ? null
                : () async {
                    await controller.saveDraft();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Draft saved')));
                    }
                  },
            child: const Text('Save draft'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: draft.body.trim().isEmpty
                  ? null
                  : () async {
                      final published = await controller.publish();
                      if (!context.mounted) return;
                      Navigator.of(context).maybePop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            published ? 'Published to Pyago' : "Saved — will publish when you're back online",
                          ),
                        ),
                      );
                    },
              child: const Text(
                'Publish',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) _OfflineNotice(scheme: scheme),
          if (draft.publishState == DraftPublishState.queuedForPublish) _QueuedNotice(scheme: scheme),
          // Live presence bar — only visible during an active collab session.
          if (_collabSessionActive)
            CollabPresenceBar(draftId: draft.id),
          // Suggestion overlay — shown for coAuthor/owner when editor-role collaborators have pending suggestions.
          if (_collabSessionActive) ...[            
            Builder(builder: (ctx) {
              final suggestions = ref
                  .watch(collabSyncServiceProvider(draft.id))
                  .collaborators
                  .values
                  .toList();
              // Only the session service knows pending suggestions.
              final pendingSuggestions = _collabSessionActive
                  ? ref.read(collabSyncServiceProvider(draft.id).notifier).pendingSuggestions
                  : [];
              return SuggestionOverlay(
                suggestions: List.from(pendingSuggestions),
                onAccept: controller.acceptSuggestion,
                onReject: controller.rejectSuggestion,
              );
            }),
          ],
          Expanded(
            child: _previewMode
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.lg),
                    child: MarkdownBody(data: draft.resolvedBody.isEmpty ? '_Nothing to preview yet._' : draft.resolvedBody),
                  )
                : _buildEditorBody(context, draft, template, controller, scheme),
          ),
          if (!_previewMode) _FormattingToolbar(onWrap: _wrapSelection, onLinePrefix: _insertLinePrefix, actions: template.enabledToolbarActions),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  tooltip: 'Add image',
                  onPressed: () async {
                    final media = await ref.read(mediaPipelineServiceProvider).pickImage();
                    if (media != null) controller.addAttachment(media);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_outlined),
                  tooltip: 'Add video',
                  onPressed: () async {
                    final media = await ref.read(mediaPipelineServiceProvider).pickVideo();
                    if (media != null) controller.addAttachment(media);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic_none_rounded),
                  tooltip: 'Record voice note',
                  onPressed: () => _showVoiceRecorderSheet(context, controller),
                ),
                const Spacer(),
                Text(
                  '${draft.wordCount} words · ${draft.readingTimeMinutes} min read',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorBody(
    BuildContext context,
    DraftModel draft,
    PostTemplate template,
    CreateController controller,
    ColorScheme scheme,
  ) {
    final editorContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _title,
            maxLength: AppConstants.maxPostTitleLength,
            style: AppTypography.serifDisplay(
              color: scheme.onSurface,
              fontSize: 26,
            ),
            decoration: InputDecoration(
              hintText: template.requiresTitle ? 'Title (required)' : 'Title (optional)',
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: false,
            ),
            onChanged: controller.updateTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final textStyle = AppTypography.displaySerif(
                color: scheme.onSurface,
                fontSize: 16,
              );
              final textPainter = TextPainter(
                text: TextSpan(text: draft.body, style: textStyle),
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              final collabState = _collabSessionActive
                  ? ref.watch(collabSyncServiceProvider(draft.id))
                  : null;
              final listCollabs = collabState?.collaborators.values.toList() ?? [];

              return Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Text(
                        _buildGhostText(draft.body, template.placeholderHints),
                        style: textStyle.copyWith(
                          color: scheme.onSurface.withOpacity(0.3),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: _body,
                    focusNode: _bodyFocusNode,
                    minLines: 12,
                    maxLines: null,
                    style: textStyle,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                    onChanged: (val) {
                      controller.updateBody(val);
                      if (_collabSessionActive) {
                        ref
                            .read(collabSyncServiceProvider(draft.id).notifier)
                            .reportCursorMoved(_body.selection.baseOffset);
                      }
                    },
                    onTap: () {
                      if (_collabSessionActive) {
                        ref
                            .read(collabSyncServiceProvider(draft.id).notifier)
                            .reportCursorMoved(_body.selection.baseOffset);
                      }
                    },
                  ),
                  if (_collabSessionActive && listCollabs.isNotEmpty)
                    Positioned.fill(
                      child: CollaboratorCursorOverlay(
                        collaborators: listCollabs,
                        textPainter: textPainter,
                        textTopLeft: Offset.zero,
                      ),
                    ),
                ],
              );
            },
          ),
          if (draft.attachments.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _AttachmentGrid(attachments: draft.attachments, controller: controller),
          ],
        ],
      ),
    );

    // Story + collab: wrap with chapter list panel.
    if (draft.type == PostType.story && _collabSessionActive && draft.blocks.isNotEmpty) {
      return Row(
        children: [
          StoryChapterList(
            draftId: draft.id,
            blocks: draft.blocks,
            onChapterTap: (_) {}, // TODO: scroll to block
            onAddChapter: () {}, // TODO: add chapter block
          ),
          Expanded(child: editorContent),
        ],
      );
    }

    return editorContent;
  }

  Future<void> _showVoiceRecorderSheet(BuildContext context, CreateController controller) async {
    final pipeline = ref.read(mediaPipelineServiceProvider);
    await pipeline.startRecording();
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.graphic_eq_rounded, size: 40),
            const SizedBox(height: 12),
            const Text('Recording…'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop & attach'),
              onPressed: () async {
                final media = await pipeline.stopRecording();
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                if (media != null) controller.addAttachment(media);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSharingSettingsSheet(
    BuildContext context,
    DraftModel draft,
    CreateController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SharingSettingsSheet(
          draft: draft,
          controller: controller,
          collabSessionActive: _collabSessionActive,
          onStartSession: () {
            Navigator.pop(ctx);
            _connectCollabSession(draft.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Collaborative session started')),
            );
          },
        );
      },
    );
  }
}

class _AttachmentGrid extends StatelessWidget {
  const _AttachmentGrid({required this.attachments, required this.controller});
  final List<MediaAttachment> attachments;
  final CreateController controller;

  @override
  Widget build(BuildContext context) {
    return _ReorderableWrap(
      attachments: attachments,
      onReorder: controller.reorderAttachments,
      onRemove: controller.removeAttachment,
    );
  }
}

class _ReorderableWrap extends StatelessWidget {
  const _ReorderableWrap({required this.attachments, required this.onReorder, required this.onRemove});

  final List<MediaAttachment> attachments;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String id) onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final a = attachments[index];
          return Padding(
            key: ValueKey(a.id),
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _AttachmentTile(attachment: a, onRemove: () => onRemove(a.id)),
          );
        },
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment, required this.onRemove});
  final MediaAttachment attachment;
  final VoidCallback onRemove;

  IconData get _icon => switch (attachment.kind) {
        MediaKind.image => Icons.image_rounded,
        MediaKind.video => Icons.videocam_rounded,
        MediaKind.audio => Icons.graphic_eq_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: scheme.primary),
              const SizedBox(height: 6),
              if (attachment.status != MediaUploadStatus.done)
                SizedBox(
                  width: 48,
                  child: LinearProgressIndicator(value: attachment.progress),
                )
              else
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
            ],
          ),
        ),
        Positioned(
          top: -6, right: -6,
          child: IconButton(
            icon: const Icon(Icons.cancel, size: 18),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _FormattingToolbar extends StatelessWidget {
  const _FormattingToolbar({required this.onWrap, required this.onLinePrefix, required this.actions});
  final void Function(String prefix, String suffix) onWrap;
  final void Function(String prefix) onLinePrefix;
  final Set<ToolbarAction> actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkSurface : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          children: [
            if (actions.contains(ToolbarAction.bold))
              IconButton(icon: const Icon(Icons.format_bold), tooltip: 'Bold', onPressed: () => onWrap('**', '**')),
            if (actions.contains(ToolbarAction.italic))
              IconButton(icon: const Icon(Icons.format_italic), tooltip: 'Italic', onPressed: () => onWrap('*', '*')),
            if (actions.contains(ToolbarAction.heading))
              IconButton(icon: const Icon(Icons.title), tooltip: 'Heading', onPressed: () => onLinePrefix('## ')),
            if (actions.contains(ToolbarAction.list))
              IconButton(icon: const Icon(Icons.format_list_bulleted), tooltip: 'List', onPressed: () => onLinePrefix('- ')),
            if (actions.contains(ToolbarAction.quote))
              IconButton(icon: const Icon(Icons.format_quote), tooltip: 'Blockquote', onPressed: () => onLinePrefix('> ')),
            if (actions.contains(ToolbarAction.sceneBreak))
              IconButton(icon: const Icon(Icons.horizontal_rule), tooltip: 'Scene Break', onPressed: () => onLinePrefix('---\n')),
          ],
        ),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, size: 16, color: scheme.onTertiaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Working offline — changes saved locally',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueuedNotice extends StatelessWidget {
  const _QueuedNotice({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: scheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: scheme.onSecondaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Queued for publish — will sync when online',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharingSettingsSheet extends ConsumerWidget {
  const _SharingSettingsSheet({
    required this.draft,
    required this.controller,
    required this.collabSessionActive,
    required this.onStartSession,
  });

  final DraftModel draft;
  final CreateController controller;
  final bool collabSessionActive;
  final VoidCallback onStartSession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final syncService = collabSessionActive
        ? ref.read(collabSyncServiceProvider(draft.id).notifier)
        : null;
    final isSimulating = syncService?.isSimulating ?? false;

    final policy = collabPolicyFor(draft.type);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Title & Close
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Private Share & Collab',
                    style: AppTypography.serifDisplay(
                      color: scheme.onSurface,
                      fontSize: 24,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Only users you invite can view and edit this collaborative entry. All formatting options and editing changes sync in real-time.',
                style: TextStyle(color: Colors.grey, height: 1.4),
              ),
              const Divider(height: 32),

              // Format Policy Card
              Text(
                'COLLABORATION POLICY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.primary.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.menu_book_rounded, color: scheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${draft.type.label} Collaboration Rules',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      policy.collabDescription,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Simulated Peer Co-Writer
              Text(
                'CO-WRITER SIMULATOR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 8),
              if (!collabSessionActive) ...[
                const Text(
                  'Please start the collaborative session first to simulate co-writers.',
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onStartSession,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Collab Session'),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.amber, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Simulate Real-Time Typing',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Watch Maya Osei type a collaborative entry into this journal character-by-character live!',
                        style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.3),
                      ),
                      const SizedBox(height: 14),
                      StatefulBuilder(
                        builder: (context, setSheetState) {
                          final liveSync = ref.read(collabSyncServiceProvider(draft.id).notifier);
                          final active = liveSync.isSimulating;

                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: active ? Colors.redAccent : scheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: () {
                              if (active) {
                                liveSync.stopRealTimeCollabSimulation();
                              } else {
                                liveSync.startRealTimeCollabSimulation();
                              }
                              setSheetState(() {});
                            },
                            child: Text(active ? 'Stop Simulation' : 'Start Simulation'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 32),

              // Collaborators list
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'COLLABORATORS (${draft.collaborators.length + 1})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      controller.inviteCollaborator('mock_invitee_${DateTime.now().millisecondsSinceEpoch}', CollaboratorRole.coAuthor);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invited new co-author')),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Invite'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Owner
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_rounded),
                title: const Text('You (Owner)'),
                subtitle: const Text('Role: Co-Author'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              // Invites
              for (final c in draft.collaborators)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.people_outline_rounded),
                  title: Text(c.inviteeUserId.contains('mock') ? 'Maya Osei' : c.inviteeUserId),
                  subtitle: Text('Role: ${c.role.name}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(c.status.name, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      if (c.status == InviteStatus.pending) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green, size: 20),
                          onPressed: () => controller.acceptInvite(c.id),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

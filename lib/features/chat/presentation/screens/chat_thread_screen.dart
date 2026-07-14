import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/shared/widgets/error_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/chat_models.dart';
import '../providers/chat_provider.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({super.key, required this.threadId, required this.title});

  final String threadId;
  final String title;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatThreadControllerProvider(widget.threadId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: state.otherPartyTyping
            ? PreferredSize(
                preferredSize: const Size.fromHeight(20),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    AppLocalizations.of(context).chatIsTyping(widget.title),
                    style: context.textTheme.bodySmall,
                  ),
                ),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(context, state)),
            _MessageComposer(controller: _controller, onSend: () {
              final text = _controller.text;
              _controller.clear();
              ref.read(chatThreadControllerProvider(widget.threadId).notifier).send(text);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ChatThreadState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.messages.isEmpty) {
      return PyagoErrorState(
        message: state.error!,
        onRetry: () => ref.invalidate(chatThreadControllerProvider(widget.threadId)),
      );
    }
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.md),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[state.messages.length - 1 - index];
        return _MessageBubble(message: message);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isMine = message.isMine;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: context.screenWidth * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              style: context.textTheme.bodyMedium?.copyWith(
                color: isMine ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            if (isMine) ...[
              const SizedBox(height: 2),
              _StatusIndicator(status: message.status, color: scheme.onPrimary.withValues(alpha: 0.75)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.status, required this.color});
  final MessageStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      MessageStatus.pending => SizedBox(
          width: 10, height: 10,
          child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
        ),
      MessageStatus.failed => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 12, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 3),
            Text('Failed', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.error)),
          ],
        ),
      MessageStatus.sent => Icon(Icons.check, size: 13, color: color),
      MessageStatus.delivered => Icon(Icons.done_all, size: 13, color: color),
      MessageStatus.read => Icon(Icons.done_all, size: 13, color: color),
    };
  }
}

class _MessageComposer extends StatelessWidget {
  const _MessageComposer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageHorizontal, AppSpacing.sm, AppSpacing.pageHorizontal, AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).chatMessageHint,
                  filled: true,
                  fillColor: context.colors.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(onPressed: onSend, icon: const Icon(Icons.arrow_upward_rounded)),
          ],
        ),
      ),
    );
  }
}

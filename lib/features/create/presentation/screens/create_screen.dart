import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/shared/widgets/pyago_badge.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../home/domain/models/post_model.dart';
import '../../data/services/media_pipeline_service.dart';
import '../../domain/models/draft_model.dart';
import '../../domain/models/media_attachment.dart';
import '../providers/create_provider.dart';

/// Pyago's writing surface. Deliberately spare — a small, selection-aware
/// formatting toolbar and media row sit in a bottom bar so the page
/// itself stays focused on the words. Works fully offline: drafts and
/// attachments are saved to local storage regardless of connectivity,
/// and publishing while offline queues instead of failing.
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

  @override
  void initState() {
    super.initState();
    if (widget.existingDraft != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(createControllerProvider.notifier).loadDraft(widget.existingDraft!);
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
    super.dispose();
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
    final scheme = Theme.of(context).colorScheme;
    final isOnline = ref.watch(isOnlineProvider).value ?? true;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Wrap(
          spacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final type in PostType.values)
              PyagoTag(
                label: type.label,
                selected: draft.type == type,
                onTap: () => controller.updateType(type),
              ),
          ],
        ),
        actions: [
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
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilledButton(
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
              child: const Text('Publish'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!isOnline) _OfflineNotice(scheme: scheme),
          if (draft.publishState == DraftPublishState.queuedForPublish) _QueuedNotice(scheme: scheme),
          Expanded(
            child: _previewMode
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.lg),
                    child: MarkdownBody(data: draft.body.isEmpty ? '_Nothing to preview yet._' : draft.body),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _title,
                          maxLength: AppConstants.maxPostTitleLength,
                          style: Theme.of(context).textTheme.headlineMedium,
                          decoration: const InputDecoration(
                            hintText: 'Title (optional)',
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          onChanged: controller.updateTitle,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _body,
                          focusNode: _bodyFocusNode,
                          minLines: 10,
                          maxLines: null,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: const InputDecoration(
                            hintText: 'Start writing… (Markdown supported: **bold**, *italic*, # heading)',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            filled: false,
                          ),
                          onChanged: controller.updateBody,
                        ),
                        if (draft.attachments.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _AttachmentGrid(attachments: draft.attachments, controller: controller),
                        ],
                      ],
                    ),
                  ),
          ),
          if (!_previewMode) _FormattingToolbar(onWrap: _wrapSelection, onLinePrefix: _insertLinePrefix),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: scheme.outline))),
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
            FilledButton.icon(
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

/// A simple drag-reorderable row of attachment thumbnails with inline
/// upload progress and a remove button per item.
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
  const _FormattingToolbar({required this.onWrap, required this.onLinePrefix});
  final void Function(String prefix, String suffix) onWrap;
  final void Function(String prefix) onLinePrefix;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.format_bold), tooltip: 'Bold', onPressed: () => onWrap('**', '**')),
          IconButton(icon: const Icon(Icons.format_italic), tooltip: 'Italic', onPressed: () => onWrap('*', '*')),
          IconButton(icon: const Icon(Icons.title), tooltip: 'Heading', onPressed: () => onLinePrefix('## ')),
          IconButton(icon: const Icon(Icons.format_list_bulleted), tooltip: 'List', onPressed: () => onLinePrefix('- ')),
          IconButton(icon: const Icon(Icons.format_quote), tooltip: 'Blockquote', onPressed: () => onLinePrefix('> ')),
        ],
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
          Text("You're offline — this will save and publish automatically once you're back online.",
              style: TextStyle(fontSize: 12, color: scheme.onTertiaryContainer)),
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
          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: scheme.onSecondaryContainer)),
          const SizedBox(width: 8),
          Text('Will publish when back online', style: TextStyle(fontSize: 12, color: scheme.onSecondaryContainer)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/empty_state.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../create/data/repositories/drafts_repository.dart';
import '../../../create/domain/models/draft_model.dart';
import '../../../../l10n/app_localizations.dart';


final draftsListProvider = Provider.autoDispose<List<DraftModel>>((ref) {
  return ref.watch(draftsRepositoryProvider).listAll();
});

class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(draftsListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Drafts')),
      body: drafts.isEmpty
          ? PyagoEmptyState(
              icon: Icons.drafts_outlined,
              title: l10n.draftsEmptyTitle,
              message: l10n.draftsEmptyBody,
              actionLabel: l10n.draftsStartWriting,
              onAction: () => context.push('/create'),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.md),
              itemCount: drafts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final draft = drafts[i];
                return Dismissible(
                  key: ValueKey(draft.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) async {
                    await ref.read(draftsRepositoryProvider).delete(draft.id);
                    ref.invalidate(draftsListProvider);
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      draft.publishState == DraftPublishState.queuedForPublish
                          ? Icons.cloud_sync_outlined
                          : Icons.description_outlined,
                    ),
                    title: Text(draft.title.isEmpty ? 'Untitled draft' : draft.title),
                    subtitle: Text(
                      draft.publishState == DraftPublishState.queuedForPublish
                          ? 'Will publish when back online'
                          : 'Saved locally · ${draft.wordCount} words'
                          '${draft.attachments.isNotEmpty ? ' · ${draft.attachments.length} attachment(s)' : ''}',
                    ),
                    onTap: () => context.push('/create', extra: draft),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/theme/app_spacing.dart';

class _Community {
  const _Community(this.name, this.memberCount, this.description);
  final String name;
  final int memberCount;
  final String description;
}

const _communities = [
  _Community('Quiet Writers', 4218, 'For people who write to think, not to perform.'),
  _Community('Midnight Poets', 2871, 'Poetry, drafted after midnight.'),
  _Community('Field Notes', 1560, 'Observational journaling and nature writing.'),
  _Community('First Drafts', 3390, 'Unedited, unfiltered, first attempts only.'),
];

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), tooltip: 'Create community', onPressed: () {})],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal, vertical: AppSpacing.md),
        itemCount: _communities.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final c = _communities[i];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            leading: PyagoAvatar(name: c.name, size: PyagoAvatarSize.lg),
            title: Text(c.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${c.description}\n${c.memberCount} members'),
            ),
            isThreeLine: true,
            trailing: OutlinedButton(onPressed: () {}, child: const Text('Join')),
          );
        },
      ),
    );
  }
}

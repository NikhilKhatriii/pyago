import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final scheme = Theme.of(context).colorScheme;

    final stats = [
      ('Pieces', '24'),
      ('Communities', '5'),
      ('Resonances', '1.2k'),
    ];

    final sections = [
      (Icons.bookmark_outline_rounded, 'Bookmarks', '/bookmarks'),
      (Icons.drafts_outlined, 'Drafts', '/drafts'),
      (Icons.groups_outlined, 'Communities', '/communities'),
      (Icons.chat_bubble_outline_rounded, 'Messages', '/chat'),
      (Icons.settings_outlined, 'Settings', '/settings'),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [scheme.primary.withValues(alpha: 0.85), scheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(color: scheme.surface, shape: BoxShape.circle),
                          child: PyagoAvatar(
                            name: user?.displayName ?? 'You',
                            imageUrl: user?.avatarUrl,
                            size: PyagoAvatarSize.xl,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton(onPressed: () {}, child: const Text('Edit profile')),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.displayName ?? 'Your name', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(
                          user != null && user.bio.isNotEmpty ? user.bio : 'No bio yet — tell people what you write about.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.65),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            for (final s in stats)
                              Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.xl),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.$2, style: Theme.of(context).textTheme.titleLarge),
                                    Text(s.$1, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        for (final s in sections)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(s.$1),
                            title: Text(s.$2),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () => context.push(s.$3),
                          ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

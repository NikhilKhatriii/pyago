import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/shared/widgets/pyago_avatar.dart';
import '../../../../core/shared/widgets/stat_pill.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/persona.dart';
import '../../../auth/domain/models/app_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      ('Words', '142k'),
      ('Minutes', '840'),
      ('Collections', '12'),
      ('Followers', '28k'),
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
          // ── Premium Profile Cover Header ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: const SizedBox.shrink(), // Remove back button on main shell tab
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/welcome_bg.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pageHorizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar Floating Alignment ─────────────────────────────
                  Transform.translate(
                    offset: const Offset(0, -48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            shape: BoxShape.circle,
                          ),
                          child: PyagoAvatar(
                            name: user?.displayName ?? 'You',
                            imageUrl: user?.avatarUrl,
                            size: PyagoAvatarSize.xl,
                            showGradientRing: true,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.switch_account_outlined),
                          tooltip: 'Switch Pen Name',
                          onPressed: user == null ? null : () => _showPersonaSwitcher(context, ref, user),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => context.push('/complete-profile'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            minimumSize: const Size(120, 42),
                          ),
                          child: const Text('Edit Profile'),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Julian Vance',
                          style: AppTypography.serifDisplay(
                            color: scheme.onSurface,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user != null && user.bio.isNotEmpty
                              ? user.bio
                              : 'Architect of words and digital curator. Exploring the intersection of human philosophy and architectural minimalism.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.65),
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Stat Pill Grid ──────────────────────────────────
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          padding: EdgeInsets.zero,
                          children: [
                            for (final s in stats)
                              StatPill(
                                value: s.$2,
                                label: s.$1,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),

                        // ── Action Sections ─────────────────────────────────
                        for (final s in sections)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.primary.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Icon(s.$1, color: scheme.primary),
                              title: Text(
                                s.$2,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: Icon(Icons.chevron_right_rounded, color: scheme.onSurface.withValues(alpha: 0.4)),
                              onTap: () {
                                if (s.$3 == '/communities') {
                                  ref.read(appRouterProvider).go('/communities');
                                } else {
                                  context.push(s.$3);
                                }
                              },
                            ),
                          ),
                        const SizedBox(height: AppSpacing.huge),
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

  void _showPersonaSwitcher(BuildContext context, WidgetRef ref, AppUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Pen Names',
                style: AppTypography.serifDisplay(
                  color: scheme.onSurface,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Publish anonymously under different personas. Real identities are never linked.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: user.personas.length,
                  itemBuilder: (context, index) {
                    final p = user.personas[index];
                    final isActive = p.id == user.activePersonaId;
                    return ListTile(
                      leading: PyagoAvatar(name: p.displayName, imageUrl: p.avatarUrl),
                      title: Text(p.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(p.bio.isNotEmpty ? p.bio : 'No bio yet'),
                      trailing: isActive ? Icon(Icons.check_circle, color: scheme.primary) : null,
                      onTap: () {
                        ref.read(authControllerProvider.notifier).switchPersona(p.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const Divider(height: 24),
              ListTile(
                leading: Icon(Icons.add_circle_outline_rounded, color: scheme.primary),
                title: const Text('Create new Pen Name', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePersonaDialog(context, ref);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showCreatePersonaDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final bioCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Pen Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Pen Name',
                  hintText: 'e.g. Silas Thorne',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bio (optional)',
                  hintText: 'A short description...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  ref.read(authControllerProvider.notifier).createPersona(
                        displayName: name,
                        bio: bioCtrl.text.trim(),
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

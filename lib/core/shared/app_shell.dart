import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';

/// The persistent bottom-navigation shell wrapping every top-level
/// destination (Home, Explore, Create, Communities, Profile). Built on
/// GoRouter's [StatefulShellRoute] so each tab keeps its own navigation
/// stack and scroll position when switching away and back.
///
/// Features a translucent glassmorphism navigation bar with pill-shaped
/// active indicator and a prominent gradient "Create" button.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded, label: 'Explore'),
    (icon: Icons.add_circle_outline_rounded, selectedIcon: Icons.add_circle_rounded, label: 'Create'),
    (icon: Icons.groups_outlined, selectedIcon: Icons.groups_rounded, label: 'Communities'),
    (icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                      .withValues(alpha: 0.75),
                  border: Border.all(
                    color: scheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_destinations.length, (index) {
                    final d = _destinations[index];
                    final isSelected = navigationShell.currentIndex == index;
                    final isCreate = index == 2;

                    if (isCreate) {
                      return _CreateButton(
                        isSelected: isSelected,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          navigationShell.goBranch(
                            index,
                            initialLocation: index == navigationShell.currentIndex,
                          );
                        },
                      );
                    }

                    return _NavItem(
                      icon: d.icon,
                      selectedIcon: d.selectedIcon,
                      label: d.label,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      },
                    );
                  }),
                ), // Row
              ), // SizedBox
            ), // Container
          ), // BackdropFilter
        ), // ClipRRect
      ), // Padding
    ), // SafeArea
  ); // Scaffold
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.5),
                  size: isSelected ? 24 : 22,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 10,
                    ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              'Create',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

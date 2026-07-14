import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The persistent bottom-navigation shell wrapping every top-level
/// destination (Home, Explore, Create, Communities, Profile). Built on
/// GoRouter's [StatefulShellRoute] so each tab keeps its own navigation
/// stack and scroll position when switching away and back.
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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

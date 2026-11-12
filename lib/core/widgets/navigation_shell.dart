import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../responsive/responsive.dart';
import '../theme/comfy_design.dart';
import 'comfy_ui.dart';

/// App shell for the five primary tabs.
///
/// Route order is the tab order: Home, Explore, Bookings, Saved, Profile.
class NavigationShell extends ConsumerWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  static const List<String> routes = <String>[
    '/',
    '/destinations',
    '/bookings',
    '/saved',
    '/profile',
  ];

  final Widget? child;

  const NavigationShell({super.key, this.child});

  static int indexFor(String path) {
    if (path == '/') return 0;
    if (path.startsWith('/destinations')) return 1;
    if (path.startsWith('/bookings')) return 2;
    if (path.startsWith('/saved')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = indexFor(path);
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.medium;
    final c = CgColors.of(context);

    void navigate(int index) {
      if (index < 0 || index >= routes.length) return;
      context.go(routes[index]);
    }

    if (wide) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                backgroundColor: c.surface,
                selectedIndex: selectedIndex,
                onDestinationSelected: navigate,
                labelType: NavigationRailLabelType.all,
                minWidth: 88,
                indicatorColor: c.mint,
                selectedIconTheme: IconThemeData(color: c.primary),
                unselectedIconTheme: IconThemeData(color: c.text2),
                selectedLabelTextStyle: CgType.l12.copyWith(
                  color: c.text,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelTextStyle: CgType.l12.copyWith(color: c.text2),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: Text('Explore'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today_rounded),
                    label: Text('Bookings'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    selectedIcon: Icon(Icons.favorite_rounded),
                    label: Text('Saved'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Profile'),
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 1, color: c.line),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      body: child ?? const SizedBox.shrink(),
      bottomNavigationBar: CgBottomNav(
        currentIndex: selectedIndex,
        onSelected: navigate,
      ),
    );
  }
}

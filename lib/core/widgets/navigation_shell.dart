import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationShell extends StatelessWidget {
  final Widget? child;
  const NavigationShell({super.key, this.child});

  static const routes = ['/', '/destinations', '/bookings', '/profile'];
  static const labels = ['Home', 'Explore', 'Bookings', 'Profile'];
  static const icons = [
    Icons.home_rounded,
    Icons.explore_rounded,
    Icons.book_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = routes.indexOf(path).clamp(0, 3);

    void navigate(int value) => context.go(routes[value]);

    final wide = MediaQuery.sizeOf(context).width >= 840;
    return Scaffold(
      body: wide
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: navigate,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (var i = 0; i < routes.length; i++)
                        NavigationRailDestination(
                          icon: Icon(icons[i]),
                          label: Text(labels[i]),
                        ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            )
          : child,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: index,
              onDestinationSelected: navigate,
              destinations: [
                for (var i = 0; i < routes.length; i++)
                  NavigationDestination(icon: Icon(icons[i]), label: labels[i]),
              ],
            ),
    );
  }
}

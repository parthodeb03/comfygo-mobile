import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../state/auth_provider.dart';

class NavigationShell extends ConsumerWidget {
  static const routes = <String>['/', '/destinations', '/bookings', '/profile'];
  final Widget? child;
  const NavigationShell({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = path == '/bookings'
        ? 1
        : path == '/profile'
            ? 2
            : 0;
    final user = ref.watch(currentUserProvider);

    void navigate(int value) {
      switch (value) {
        case 0:
          context.go('/destinations');
          return;
        case 1:
          context.go('/bookings');
          return;
        case 2:
          context.go('/profile');
          return;
      }
    }

    final wide = MediaQuery.sizeOf(context).width >= 840;
    return Scaffold(
      body: wide
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: navigate,
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.search, size: 30),
                        label: Text('Search'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bookmark_border, size: 30),
                        label: Text('Bookings'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person, size: 30),
                        label: Text('Profile'),
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
          : BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: navigate,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 30),
                  label: '',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border, size: 30),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 15,
                    backgroundImage: user?.profileImage?.isNotEmpty == true
                        ? NetworkImage(user!.profileImage!)
                        : null,
                    child: user?.profileImage?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, size: 18),
                  ),
                  label: '',
                ),
              ],
            ),
    );
  }
}



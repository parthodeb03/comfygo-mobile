// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';
import '../../../state/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Quick links to every bookable section, mirroring the Home shortcuts.
  static const _explore = <({String label, IconData icon, String route})>[
    (
      label: 'Hotels',
      icon: Icons.hotel_rounded,
      route: '/hotels',
    ),
    (
      label: 'Transport',
      icon: Icons.directions_bus_rounded,
      route: '/transports',
    ),
    (
      label: 'Guides',
      icon: Icons.record_voice_over_rounded,
      route: '/guides',
    ),
    (
      label: 'Packages',
      icon: Icons.luggage_rounded,
      route: '/packages',
    ),
    (
      label: 'Spots',
      icon: Icons.camera_alt_outlined,
      route: '/spots',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = CgColors.of(context);
    final user = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final name = (user?.fullName.trim().isNotEmpty ?? false)
        ? user!.fullName.trim()
        : 'Partho';
    final email = (user?.email.trim().isNotEmpty ?? false)
        ? user!.email.trim()
        : 'partho@example.com';
    final initial = name.characters.first.toUpperCase();

    return Scaffold(
      backgroundColor: c.bg,
      body: CgBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 40, bottom: 32),
            children: [
              Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initial,
                      style: CgType.t20.copyWith(
                        fontSize: 24,
                        color: c.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.t20.copyWith(color: c.text),
                  ),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.b14.copyWith(color: c.text2),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: CgSection(title: 'Explore'),
              ),
              SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  itemCount: _explore.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = _explore[index];
                    return CgPressable(
                      onTap: () => context.push(item.route),
                      child: CgCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: SizedBox(
                          width: 72,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: c.gMint,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 22,
                                  color: c.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CgType.l12.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: c.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    CgPressable(
                      onTap: () =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                      child: CgCard(
                        child: SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.dark_mode_outlined,
                                  size: 22,
                                  color: c.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Dark mode',
                                    style: CgType.t16.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: c.text,
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 46,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: isDark ? c.primary : c.line,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: isDark
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 3,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CgPressable(
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                      child: CgCard(
                        child: SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sign out',
                                style: CgType.t16.copyWith(
                                  color: CgColorConstants.danger,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

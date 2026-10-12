import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';
import '../../../state/service_providers.dart';
import '../../../state/theme_provider.dart';
import '../../../models/models.dart';
import '../../../data/tourist_spots.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final bookings = ref.watch(bookingsProvider).bookings;
    final totalBookings = bookings.length;
    final upcoming = bookings
        .where(
          (b) =>
              b.status == BookingStatus.pending ||
              b.status == BookingStatus.confirmed,
        )
        .length;
    final initials = (user?.fullName ?? 'G U')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: NatureBackground.wrap(child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ─── Back to home ──────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: AppColors.greenSoft(context),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => goBack(context),
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.accentGreen(context),
                        semanticLabel: 'Back',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ─── Avatar + Name ─────────────────────────────
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary(context),
                child: ClipOval(
                  child: SizedBox.expand(
                    child:
                        user?.profileImage != null &&
                            user!.profileImage!.isNotEmpty
                        ? Image.network(
                            user.profileImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _avatarFallback(initials),
                          )
                        : _avatarFallback(initials),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.fullName ?? 'Guest User',
                style:  TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'guest@example.com',
                style:  TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
              ),

              if (user?.nationality?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(user!.nationality!, textAlign: TextAlign.center),
              ],
              const SizedBox(height: 20),

              // ─── Role badge ────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _roleLabel(user?.role.name ?? 'tourist'),
                        style:  TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Quick stats ───────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.divider(context),
                    width: 0.5,
                  ),
                ),                  child: Row(
                    children: [
                      _StatItem(
                        icon: Icons.book_rounded,
                        value: '$totalBookings',
                        label: 'Bookings',
                      ),
                      const _Divider(),
                      _StatItem(
                        icon: Icons.upcoming_rounded,
                        value: '$upcoming',
                        label: 'Upcoming',
                      ),
                      const _Divider(),
                      const _StatItem(
                        icon: Icons.card_giftcard_rounded,
                        value: 'Basic',
                        label: 'Plan',
                      ),
                    ],
                  ),
              ),

              const SizedBox(height: 24),

              // ─── Account section ────────────────────────────
              _SectionHeader(title: 'Account'),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    color: AppColors.primary(context),
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _SettingsTile(
                    icon: Icons.card_membership_rounded,
                    color: const Color(0xFFFFB300),
                    title: 'My Package',
                    subtitle: 'Basic (Free)',
                    onTap: () => context.push('/packages'),
                  ),
                  _SettingsTile(
                    icon: Icons.book_outlined,
                    color: const Color(0xFF4CAF50),
                    title: 'My Bookings',
                    subtitle: 'View and manage your trips',
                    onTap: () => context.push('/bookings'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Appearance ────────────────────────────────
              _SectionHeader(title: 'Appearance'),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: isDark
                        ? const Color(0xFF7E57C2)
                        : const Color(0xFFFFB300),
                    title: 'Dark mode',
                    subtitle: isDark
                        ? 'On — easy on the eyes at night'
                        : 'Off — bright and clear',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (_) =>
                          ref.read(themeProvider.notifier).toggleTheme(),
                    ),
                    onTap: () =>
                        ref.read(themeProvider.notifier).toggleTheme(),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Preferences section ────────────────────────
              _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.landscape_outlined,
                    color: AppColors.primary(context),
                    title: 'Tourist Spots',
                    subtitle: '${touristSpots.length} places, division-wise',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/spots'),
                  ),
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    color: AppColors.brandGreen,
                    title: 'Help & Support',
                    subtitle: 'FAQs, contact us, feedback',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/help'),
                  ),
                  _SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    color: const Color(0xFF1B7A4F),
                    title: 'Contact Us',
                    subtitle: 'Send us a message',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/contact'),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    color: AppColors.textSecondary(context),
                    title: 'About',
                    subtitle: 'App version 1.0.0',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/about'),
                  ),
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    color: const Color(0xFF7E57C2),
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/privacy'),
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    color: const Color(0xFFFF8F50),
                    title: 'Terms of Service',
                    subtitle: 'Rules for using ComfyGo',
                    trailing:  Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint(context),
                    ),
                    onTap: () => context.push('/terms'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Admin (hidden) ─────────────────────────────
              if (user?.role == UserRole.admin) ...[
                _SettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.admin_panel_settings_outlined,
                      color: OneUIColors.error,
                      title: 'Admin Panel',
                      subtitle: 'Manage users, bookings & listings',
                      trailing:  Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textHint(context),
                      ),
                      onTap: () => context.push('/admin'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // ─── Sign out ───────────────────────────────────
              CGButton(
                label: 'Sign Out',
                isOutlined: true,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      )),
    );
  }

  Widget _avatarFallback(String initials) {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'tourist':
        return 'Tourist';
      case 'guide':
        return 'Guide';
      case 'hotelManager':
        return 'Hotel Manager';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primary(context)),
          const SizedBox(height: 4),
          Text(
            value,
            style:  TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          Text(
            label,
            style:  TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: AppColors.divider(context));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style:  TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(context),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
               Divider(
                height: 1,
                indent: 64,
                color: AppColors.divider(context),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:  TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style:  TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

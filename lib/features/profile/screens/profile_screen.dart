import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';
import '../../../models/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final initials = (user?.fullName ?? 'G U')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ─── Avatar + Name ─────────────────────────────
              CircleAvatar(
                radius: 44,
                backgroundColor: OneUIColors.primaryLight,
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: OneUIColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'guest@example.com',
                style: const TextStyle(
                  fontSize: 14,
                  color: OneUIColors.textSecondaryLight,
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
                  color: OneUIColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: OneUIColors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _roleLabel(user?.role.name ?? 'tourist'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: OneUIColors.primaryLight,
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
                  color: OneUIColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: OneUIColors.dividerLight,
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  children: [
                    _StatItem(
                      icon: Icons.book_rounded,
                      value: '—',
                      label: 'Bookings',
                    ),
                    _Divider(),
                    _StatItem(
                      icon: Icons.star_rounded,
                      value: '—',
                      label: 'Reviews',
                    ),
                    _Divider(),
                    _StatItem(
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
                    color: OneUIColors.primaryLight,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    onTap: () {},
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

              // ─── Preferences section ────────────────────────
              _SectionHeader(title: 'Preferences'),
              const SizedBox(height: 8),
              _SettingsGroup(
                children: [
                  _SettingsTile(
                    icon: Icons.help_outline_rounded,
                    color: const Color(0xFF2196F3),
                    title: 'Help & Support',
                    subtitle: 'FAQs, contact us, feedback',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: OneUIColors.textHintLight,
                    ),
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    color: OneUIColors.textSecondaryLight,
                    title: 'About',
                    subtitle: 'App version 1.0.0',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: OneUIColors.textHintLight,
                    ),
                    onTap: () {},
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
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: OneUIColors.textHintLight,
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
      ),
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
          Icon(icon, size: 20, color: OneUIColors.primaryLight),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: OneUIColors.textPrimaryLight,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: OneUIColors.textSecondaryLight,
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
    return Container(width: 1, height: 32, color: OneUIColors.dividerLight);
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
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: OneUIColors.textPrimaryLight,
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
        color: OneUIColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OneUIColors.dividerLight, width: 0.5),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                indent: 64,
                color: OneUIColors.dividerLight,
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: OneUIColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OneUIColors.textSecondaryLight,
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

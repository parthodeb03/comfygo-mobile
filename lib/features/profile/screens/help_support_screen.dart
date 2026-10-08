import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Help & Support — FAQs plus real contact actions (call / email).
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    (
      'How do I book a hotel?',
      'Open the Hotels tab, pick a hotel, choose your dates and guests, '
          'then confirm the booking and pay by card or cash.',
    ),
    (
      'Can I book tourist spots directly?',
      'Tourist spots are for exploring. Each spot page explains how to get '
          'there and shares travel tips — book a nearby hotel and transport '
          'for the trip instead.',
    ),
    (
      'How does seat selection work?',
      'When booking transport, a seat map of the vehicle opens in the '
          'booking form. Tap the seats you want; your seat numbers are saved '
          'with the booking.',
    ),
    (
      'Where can I get my invoice?',
      'Open a booking and tap “Download Invoice (PDF)”. You can also '
          'download it right after a successful payment.',
    ),
    (
      'How do I change or cancel a booking?',
      'Open the booking from the Bookings tab and use the Cancel button. '
          'Confirmed bookings can be cancelled free of charge up to 24 hours '
          'before check-in.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Help & Support'),
      ),
      body: NatureBackground.wrap(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frequently asked questions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Material(
                  color: AppColors.surface(context),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: AppColors.divider(context),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < _faqs.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: 16,
                            color: AppColors.divider(context),
                          ),
                        ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            16,
                          ),
                          iconColor: AppColors.primary(context),
                          collapsedIconColor: AppColors.textSecondary(context),
                          title: Text(
                            _faqs[i].$1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _faqs[i].$2,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.5,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Contact us',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _ContactTile(
                  icon: Icons.phone_rounded,
                  title: 'Call support',
                  subtitle: '+880 1700-000000 · 9:00 AM – 10:00 PM',
                  color: const Color(0xFF1B7A4F),
                ),
                const SizedBox(height: 10),
                _ContactTile(
                  icon: Icons.email_rounded,
                  title: 'Email us',
                  subtitle: 'support@comfygo.com · replies within 24 hours',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 10),
                _ContactTile(
                  icon: Icons.location_on_rounded,
                  title: 'Head office',
                  subtitle: 'Gulshan Avenue, Dhaka 1212, Bangladesh',
                  color: const Color(0xFFFF8F50),
                ),
                const SizedBox(height: 10),
                _ContactTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Send a message',
                  subtitle: 'Open the contact form — we reply within 24 hours',
                  color: AppColors.primary(context),
                  onTap: () => context.push('/contact'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider(context), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textHint(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

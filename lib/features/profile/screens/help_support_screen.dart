// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';

/// Help & Support — FAQs plus real contact actions (call / email).
class HelpSupportScreen extends StatelessWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
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
    final c = CgColors.of(context);
    return CgPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Help & Support',
            subtitle: 'Answers and ways to reach us',
            onBack: () => goBack(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              'Frequently asked questions',
              style: CgType.t16.copyWith(fontSize: 18, color: c.text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: CgCard(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < _faqs.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: c.line),
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
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
                        iconColor: c.primary,
                        collapsedIconColor: c.text2,
                        shape: const Border(),
                        collapsedShape: const Border(),
                        title: Text(
                          _faqs[i].$1,
                          style: CgType.b14.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _faqs[i].$2,
                              style: CgType.b14.copyWith(
                                fontSize: 13.5,
                                height: 1.5,
                                color: c.text2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              'Contact us',
              style: CgType.t16.copyWith(fontSize: 18, color: c.text),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                const CgTile(
                  icon: Icons.phone_rounded,
                  title: 'Call support',
                  subtitle: '+880 1700-000000 · 9:00 AM – 10:00 PM',
                  trailing: SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                const CgTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Email us',
                  subtitle: 'support@comfygo.com · replies within 24 hours',
                  trailing: SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                const CgTile(
                  icon: Icons.place_outlined,
                  title: 'Head office',
                  subtitle: 'Gulshan Avenue, Dhaka 1212, Bangladesh',
                  trailing: SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                CgTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Send a message',
                  subtitle: 'Open the contact form — we reply within 24 hours',
                  onTap: () => context.push('/contact'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

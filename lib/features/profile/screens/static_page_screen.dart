// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';

/// Content data for a static info page.
class StaticPageData { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  final String title;
  final IconData icon;
  final List<StaticSection> sections;

  const StaticPageData({
    required this.title,
    required this.icon,
    required this.sections,
  });
}

class StaticSection {
  final String heading;
  final List<String> paragraphs;

  const StaticSection(this.heading, this.paragraphs);
}

/// Shared renderer for the app's static pages: About ComfyGo,
/// Privacy Policy and Terms of Service.
class StaticPageScreen extends StatelessWidget {
  final StaticPageData page;

  const StaticPageScreen({super.key, required this.page});

  // ── Prebuilt pages ──────────────────────────────────────────────────────

  static const about = StaticPageData(
    title: 'About ComfyGo',
    icon: Icons.explore_rounded,
    sections: [
      StaticSection('Who we are', [
        'ComfyGo is a Bangladesh domestic-tourism platform built to make '
            'planning a trip inside the country simple, transparent and fast.',
        'From the beaches of Cox\'s Bazar to the tea gardens of Sylhet, the '
            'mangroves of the Sundarbans to the peaks of Bandarban — if it is '
            'worth visiting in Bangladesh, it belongs on ComfyGo.',
      ]),
      StaticSection('What you can do', [
        'Browse destinations, hotels, transports and licensed guides with '
            'real photos, reviews and honest pricing in Bangladeshi Taka.',
        'Plan a whole trip in one place: pick dates, choose seats, book a '
            'guide, and pay with bKash, Nagad, card or cash on arrival.',
        'Manage everything from your profile — bookings, favourites, '
            'invoices and your package tier.',
      ]),
      StaticSection('Our promise', [
        'No hidden fees. Every price you see includes the breakdown before '
            'you pay, and every payment is recorded with a transaction ID.',
      ]),
    ],
  );

  static const privacy = StaticPageData(
    title: 'Privacy Policy',
    icon: Icons.privacy_tip_rounded,
    sections: [
      StaticSection('What we collect', [
        'Account details you provide: full name, email address, phone number '
            'and password (stored only as a bcrypt hash — never in plain text).',
        'Trip data you create: bookings, payments, favourites, reviews and '
            'messages you send through the contact form.',
        'Technical data: anonymous error and health-check information used to '
            'keep the service reliable.',
      ]),
      StaticSection('How we use it', [
        'To provide the service: confirm bookings, process payments, show '
            'your booking history and personalise your recommendations.',
        'To communicate with you about your bookings and support requests.',
        'To keep the platform secure — including rate limiting on sign-in '
            'and password-reset attempts.',
      ]),
      StaticSection('What we never do', [
        'We never sell your personal data to third parties.',
        'We never store full card numbers or wallet PINs — card payments run '
            'in sandbox mode and wallet payments only keep your wallet number.',
        'Payment records are visible to administrators for auditing, refunds '
            'and fraud prevention.',
      ]),
      StaticSection('Your rights', [
        'You can update your profile information at any time from the '
            'Profile screen. To request deletion of your account and its '
            'data, contact us through the Contact Us screen.',
      ]),
    ],
  );

  static const terms = StaticPageData(
    title: 'Terms of Service',
    icon: Icons.description_rounded,
    sections: [
      StaticSection('1. Using ComfyGo', [
        'You must be at least 18 years old, or use the service with parental '
            'consent. You are responsible for keeping your account credentials '
            'secure and for all activity under your account.',
        'Provide accurate information when booking — hotels and operators may '
            'refuse a reservation that contains false guest details.',
      ]),
      StaticSection('2. Bookings & cancellation', [
        'A booking is an offer to purchase. It becomes confirmed once '
            'payment is completed (or, for cash payments, once our team '
            'confirms collection).',
        'Pending bookings can be cancelled by you at any time from the '
            'Bookings screen. Confirmed bookings follow the cancellation '
            'policy of the individual hotel or transport operator.',
        'Listings may be deactivated or removed by administrators or their '
            'owners; we will notify affected guests when this happens to an '
            'upcoming booking.',
      ]),
      StaticSection('3. Payments', [
        'bKash, Nagad and card payments in this build run in sandbox mode: '
            'they are simulated and do not move real money. Cash payments are '
            'collected on arrival.',
        'All payments are recorded with a transaction ID for auditing. Admins '
            'can void or refund records where appropriate.',
      ]),
      StaticSection('4. Packages & subscriptions', [
        'Subscription tiers (Basic, Pro, Premium, Ultimate) run monthly and '
            'can be upgraded at any time. Benefits apply from the moment of '
            'purchase until the end of the paid period.',
      ]),
      StaticSection('5. Reviews & content', [
        'Reviews may only be left on completed bookings. Content that is '
            'abusive, discriminatory or promotional may be removed.',
      ]),
      StaticSection('6. Liability', [
        'ComfyGo is an intermediary between travellers and service '
            'providers. We are not responsible for the acts of hotels, '
            'transport operators or guides, though we act on verified '
            'complaints promptly.',
      ]),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(title: page.title, onBack: () => goBack(context)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < page.sections.length; i++) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        page.sections[i].heading,
                        style: CgType.t16.copyWith(color: c.text),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final paragraph in page.sections[i].paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          paragraph,
                          style: CgType.b14.copyWith(
                            color: c.text2,
                            height: 1.6,
                          ),
                        ),
                      ),
                    if (i != page.sections.length - 1) ...[
                      Divider(color: c.line, height: 24),
                      const SizedBox(height: 8),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'ComfyGo — Dhaka, Bangladesh',
              style: CgType.l12.copyWith(color: c.text2),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

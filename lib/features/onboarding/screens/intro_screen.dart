import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../features/onboarding/screens/splash_screen.dart';

/// First-run introduction slides (shown once, before login).
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.explore_rounded,
      title: 'Discover Bangladesh',
      body:
          'From the beaches of Cox\'s Bazar to the tea gardens of Sylhet — '
          'explore destinations hand-picked for every kind of traveler.',
      image: 'assets/images/bg_sundarbans.jpg',
    ),
    _SlideData(
      icon: Icons.hotel_rounded,
      title: 'Book Stays & Transport',
      body:
          'Hotels, buses, trains and guides in one place. Pick your dates, '
          'choose your seats, and pay with bKash, Nagad, card or cash.',
      image: 'assets/images/bg_hotels.jpg',
    ),
    _SlideData(
      icon: Icons.confirmation_number_rounded,
      title: 'Trips in One Tap',
      body:
          'Your bookings, tickets and invoices stay together — confirm, '
          'cancel or review every trip from your profile.',
      image: 'assets/images/bg_bookings.jpg',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SplashScreen.introSeenKey, true);
    if (!mounted) return;
    context.go('/login');
  }

  void _next() {
    if (_page < _slides.length - 1) {
      _controller.nextPage(
        duration: OneUISpacing.animSlow,
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _buildSlide(_slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _page;
                      return AnimatedContainer(
                        duration: OneUISpacing.animNormal,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary(context)
                              : AppColors.divider(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: OneUISpacing.xxl),
                  CGButton(
                    label: isLast ? 'Get Started' : 'Next',
                    onPressed: isLast ? _finish : _next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: 'intro-${slide.title}',
            child: Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: AssetImage(slide.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(slide.icon, size: 26, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: OneUISpacing.xxxl),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: OneUISpacing.md),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String title;
  final String body;
  final String image;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.body,
    required this.image,
  });
}

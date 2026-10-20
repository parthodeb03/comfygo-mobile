import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';

/// Shared sage artwork + white sheet used by Sign In and Sign Up.
class CgAuthShell extends StatelessWidget {
  const CgAuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.body,
    this.onArtworkTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget body;
  final VoidCallback? onArtworkTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CgColors.light.bg,
      body: CgBackground(
        gradient: CgColors.light.gSage,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      CgRoundButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 18,
                        semanticLabel: 'Back',
                        onTap: onBack,
                      ),
                      const Spacer(),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onArtworkTap,
                        child: SizedBox(
                          width: 64,
                          height: 72,
                          child: SvgPicture.asset(
                            'assets/illustrations/mango.svg',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: CgType.t20.copyWith(
                          fontSize: 28,
                          height: 34 / 28,
                          color: CgColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: CgType.b14.copyWith(color: CgColors.inkSoft),
                      ),
                    ],
                  ),
                ),
                CgSheet(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

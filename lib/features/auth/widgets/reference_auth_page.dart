// Shared sign-in / sign-up page frame from the reference UI.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'reference_art.dart';
import 'reference_controls.dart';
import 'reference_theme.dart';

/// Artwork header + white form sheet, exactly as the reference stacks them.
///
/// The sheet is pulled 24dp over the photo (CSS `-mt-6`) so its rounded top
/// corners reveal the artwork behind it, and the page gradient stays visible
/// underneath it.
class CgAuthPage extends StatelessWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const CgAuthPage({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.onHeaderTap,
  });

  /// Sheet headline (`Welcome back`, `Create account`, …).
  final String title;

  final Widget body;
  final VoidCallback? onBack;

  /// Optional tap target over the artwork brand block (hidden admin login).
  final VoidCallback? onHeaderTap;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final bottomInset = media.padding.bottom;

    return Scaffold(
      backgroundColor: c.bg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        // `SizedBox.expand` keeps the page gradient full-bleed even when the
        // form is shorter than the viewport.
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: c.gBg),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CgPhotoHeader(
                    height: 330 + topInset,
                    topPadding: topInset,
                    onBack: onBack,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onHeaderTap,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ComfyGo',
                            style: CgRefType.display.copyWith(
                              color: CgRefColors.onArt,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Travel Bangladesh, comfortably.',
                            style: CgRefType.body.copyWith(
                              color: Colors.white.withValues(alpha: .90),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // CSS `-mt-6`: the sheet rides 24dp up over the artwork.
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: CgRefSheet(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        32 + bottomInset,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: CgRefType.headline.copyWith(color: c.text),
                          ),
                          const SizedBox(height: 20),
                          body,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

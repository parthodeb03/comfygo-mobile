// ComfyGo Project Plan — phase map (plan §07, Development Milestones)
//
// The submission document splits the work into three phases. Every source file
// carries a matching tag at the top so the phase a piece of work belongs to is
// visible where it lives:
//
//   Phase 1  Foundation and UI        (20 Sep – 4 Oct 2026)
//            Project setup, folders, theme, routes, reusable widgets and the
//            main screen structures with mock data.
//   Phase 2  Core Features and Data   (5 Oct – 1 Nov 2026)
//            Models, REST services and Provider classes, validated forms,
//            local settings, search, booking flow and role dashboards.
//   Phase 3  Testing and Finalization (2 Nov – 22 Nov 2026)
//            Unit, widget and flow tests, defect fixes, error states,
//            responsiveness, accessibility and release documentation.
//
// This entry point is Phase 2 wiring: it mounts the Phase 1 theme and router
// and starts the Phase 2 health check behind the Phase 3 offline banner.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/comfy_theme.dart';
import 'core/theme/theme.dart';
import 'core/widgets/offline_banner.dart';
import 'core/router/app_router.dart';
import 'core/services/network_service.dart';
import 'state/auth_provider.dart';
import 'state/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    return true;
  };

  runApp(const ProviderScope(child: ComfyGoApp()));
}

class ComfyGoApp extends ConsumerStatefulWidget {
  const ComfyGoApp({super.key});

  @override
  ConsumerState<ComfyGoApp> createState() => _ComfyGoAppState();
}

class _ComfyGoAppState extends ConsumerState<ComfyGoApp> {
  bool _backendHealthy = true; // Assume healthy first
  bool _showOfflineBanner = false;
  Timer? _healthTimer;

  @override
  void initState() {
    super.initState();
    // Start health check in background after a short delay
    _healthTimer = Timer(const Duration(seconds: 2), _checkBackend);
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkBackend() async {
    final healthy = await checkBackendHealth();
    if (!mounted) return;

    setState(() {
      _backendHealthy = healthy;
      _showOfflineBanner = !healthy;
    });

    // Auto-retry every 10 seconds if backend is down
    if (!healthy) {
      _healthTimer?.cancel();
      _healthTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _retryBackend(),
      );
    } else {
      _healthTimer?.cancel();
    }
  }

  Future<void> _retryBackend() async {
    final healthy = await checkBackendHealth();
    if (!mounted) return;

    if (healthy && !_backendHealthy) {
      // Backend came back online!
      setState(() {
        _backendHealthy = true;
        _showOfflineBanner = false;
      });
      _healthTimer?.cancel();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backend reconnected!'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);

    return MaterialApp.router(
      title: 'ComfyGo',
      debugShowCheckedModeBanner: false,
      theme: CgTheme.light,
      darkTheme: CgTheme.dark,
      themeMode: themeState.themeMode,
      routerConfig: router,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: themeState.isDarkMode
              ? const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                )
              : const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
          child: Stack(
            children: [
              // Main app content
              authState.isInitialized ? child! : _buildLoadingScreen(),

              // Offline banner (non-blocking, at the top)
              if (_showOfflineBanner)
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: 0,
                  right: 0,
                  child: OfflineBanner(onRetry: _retryBackend),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: Semantics(
          label: 'Loading ComfyGo',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: OneUISpacing.avatarXl,
                height: OneUISpacing.avatarXl,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer(context),
                  borderRadius: BorderRadius.circular(OneUISpacing.radiusXl),
                ),
                child: Icon(
                  Icons.flight_takeoff_rounded,
                  size: OneUISpacing.iconXl,
                  color: AppColors.onPrimaryContainer(context),
                ),
              ),
              const SizedBox(height: OneUISpacing.xxl),
              Text(
                'ComfyGo',
                style: Theme.of(context).textTheme.displaySmall
                    ?.copyWith(color: AppColors.textPrimary(context)),
              ),
              const SizedBox(height: OneUISpacing.lg),
              CircularProgressIndicator(color: AppColors.primary(context)),
            ],
          ),
        ),
      ),
    );
  }
}

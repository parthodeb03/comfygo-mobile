import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';
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
      theme: OneUITheme.lightTheme,
      darkTheme: OneUITheme.darkTheme,
      themeMode: themeState.themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            // Main app content
            authState.isInitialized ? child! : _buildLoadingScreen(),

            // Offline banner (non-blocking, at the top)
            if (_showOfflineBanner)
              Positioned(
                top: MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                child: _buildOfflineBanner(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: OneUIColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(OneUISpacing.radiusXl),
              ),
              child: const Icon(
                Icons.flight_takeoff_rounded,
                size: 40,
                color: OneUIColors.primaryLight,
              ),
            ),
            const SizedBox(height: OneUISpacing.xxl),
            const Text(
              'ComfyGo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: OneUIColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: OneUISpacing.lg),
            const CircularProgressIndicator(color: OneUIColors.primaryLight),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: Color(0xFFE65100),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Backend offline',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
                Text(
                  'Start server or run start.bat',
                  style: TextStyle(fontSize: 11, color: Color(0xFFBF360C)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _retryBackend,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

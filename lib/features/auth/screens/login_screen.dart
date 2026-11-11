// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Sign-in screen transcribed from the reference UI; form validation and the
// API call are the Phase 2 work it wraps.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';
import '../widgets/reference_auth_page.dart';
import '../widgets/reference_controls.dart';
import '../widgets/reference_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'ahmed@email.com');
  final _passwordController = TextEditingController(text: 'password123');
  bool _loading = false;
  String? _error;
  int _logoTaps = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_loading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Use at least 6 characters');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final success = await ref
        .read(authProvider.notifier)
        .login(email: email, password: password);

    if (!mounted) return;
    if (success) {
      context.go('/');
      return;
    }

    setState(() {
      _loading = false;
      _error = ref.read(authProvider).error ?? 'Unable to sign in right now';
    });
  }

  void _handleLogoTap() {
    _logoTaps++;
    if (_logoTaps >= 5) {
      _logoTaps = 0;
      context.push('/admin-login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    return CgAuthPage(
      title: 'Welcome back',
      onBack: () => context.go('/welcome'),
      onHeaderTap: _handleLogoTap,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RefLabel(text: 'Email address'),
          const SizedBox(height: 8),
          CgRefField(
            controller: _emailController,
            hint: 'partho@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              const _RefLabel(text: 'Password'),
              CgPressable(
                onTap: _loading ? null : () => context.push('/forgot-password'),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      'Forgot password?',
                      style: CgRefType.label.copyWith(
                        color: c.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CgRefField(
            controller: _passwordController,
            hint: 'Password',
            obscure: true,
            textInputAction: TextInputAction.done,
            enabled: !_loading,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _signIn(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            CgRefError(message: _error!),
            const SizedBox(height: 16),
          ],
          CgRefButton(
            expand: true,
            loading: _loading,
            onTap: _signIn,
            semanticLabel: 'Sign in',
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'New to ComfyGo? ',
                style: CgRefType.bodyS.copyWith(color: c.text2),
              ),
              CgRefLink(
                label: 'Create an account',
                color: c.primary,
                minHeight: 28,
                onTap: _loading ? null : () => context.go('/signup'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RefLabel extends StatelessWidget {
  const _RefLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: CgRefType.label.copyWith(color: CgRefColors.of(context).text2),
    );
  }
}

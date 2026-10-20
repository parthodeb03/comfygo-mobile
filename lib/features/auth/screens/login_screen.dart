import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';
import '../widgets/auth_shell.dart';

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
    final c = CgColors.of(context);
    return CgAuthShell(
      title: 'Welcome back',
      subtitle: 'Sign in to continue your journey',
      onBack: () => context.go('/intro'),
      onArtworkTap: _handleLogoTap,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CgTextField(
            label: 'Email address',
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 16),
          CgTextField(
            label: 'Password',
            controller: _passwordController,
            icon: Icons.lock_outline_rounded,
            hint: 'Enter your password',
            obscure: true,
            textInputAction: TextInputAction.done,
            enabled: !_loading,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _signIn(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () => context.push('/forgot-password'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: const Size(0, 40),
                foregroundColor: c.primary,
              ),
              child: Text(
                'Forgot password?',
                style: CgType.b14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: CgColorConstants.danger,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _error!,
                    style: CgType.l12.copyWith(
                      color: CgColorConstants.danger,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          CgPillButton(
            width: double.infinity,
            loading: _loading,
            onTap: _signIn,
            semanticLabel: 'Sign in',
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 20),
          _SocialDivider(color: c.text2, line: c.line),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  label: 'Google',
                  mark: 'G',
                  markColor: const Color(0xFFEA4335),
                  onTap: () => showCgToast(context, 'Google sign-in is a demo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SocialButton(
                  label: 'Facebook',
                  mark: 'f',
                  markColor: const Color(0xFF1877F2),
                  onTap: () =>
                      showCgToast(context, 'Facebook sign-in is a demo'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Don’t have an account? ',
                style: CgType.b14.copyWith(color: c.text2),
              ),
              GestureDetector(
                onTap: _loading ? null : () => context.go('/signup'),
                child: Text(
                  'Sign Up',
                  style: CgType.b14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.text,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider({required this.color, required this.line});

  final Color color;
  final Color line;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: line)),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'or continue with',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: CgType.l12.copyWith(color: color),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: line)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.mark,
    required this.markColor,
    required this.onTap,
  });

  final String label;
  final String mark;
  final Color markColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.line, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mark,
              style: CgType.b14.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: markColor,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CgType.b14.copyWith(
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

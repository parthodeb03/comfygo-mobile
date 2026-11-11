// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';
import '../widgets/mountain_hero.dart';

/// Forgot password — 3-step flow matching the spec:
///   1. enter email → 6-digit code is issued
///   2. verify the 6-digit code
///   3. set a new password
///
/// Lays over a full-screen mountain photo with a frosted glass card so there
/// is no empty section behind the form.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _step = 1; // 1 = email, 2 = code, 3 = new password

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  String? _resetToken;
  String? _devCode; // shown only when the backend echoes it (no email provider)

  String? _emailError;
  String? _codeError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    if (mounted) showCgToast(context, message);
  }

  void _goBackStep() {
    if (_isLoading) return;
    if (_step > 1) {
      setState(() {
        _step -= 1;
        _codeError = null;
        _passwordError = null;
        _confirmError = null;
      });
    } else {
      goBack(context);
    }
  }

  // ── Step 1: request code ────────────────────────────────────────────────

  Future<void> _requestCode() async {
    final email = _emailController.text.trim();
    final error = email.isEmpty
        ? 'Enter your email'
        : !email.contains('@')
        ? 'Enter a valid email'
        : null;
    if (error != null) {
      setState(() => _emailError = error);
      return;
    }
    setState(() {
      _emailError = null;
      _isLoading = true;
    });

    final result = await ref
        .read(authProvider.notifier)
        .requestCode(email: email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result) {
        _step = 2;
        _devCode = ref.read(authProvider.notifier).lastResetCode;
      }
    });
    if (!result) {
      _showSnack(ref.read(authProvider).error ?? 'Could not send the code');
    }
  }

  // ── Step 2: verify code ─────────────────────────────────────────────────

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _codeError = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _codeError = null;
      _isLoading = true;
    });

    final result = await ref
        .read(authProvider.notifier)
        .verifyResetCode(email: _emailController.text.trim(), code: code);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result) {
        _step = 3;
        _resetToken = ref.read(authProvider.notifier).lastResetToken;
      }
    });
    if (!result) {
      _showSnack(ref.read(authProvider).error ?? 'Invalid or expired code');
    }
  }

  // ── Step 3: set new password ────────────────────────────────────────────

  String? _validatePassword(String value) {
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) return 'Add a letter';
    if (!RegExp(r'\d').hasMatch(value)) return 'Add a number';
    return null;
  }

  Future<void> _setPassword() async {
    final passwordError = _validatePassword(_passwordController.text);
    final confirmError = _confirmController.text != _passwordController.text
        ? 'Passwords do not match'
        : null;
    if (passwordError != null || confirmError != null) {
      setState(() {
        _passwordError = passwordError;
        _confirmError = confirmError;
      });
      return;
    }
    setState(() {
      _passwordError = null;
      _confirmError = null;
      _isLoading = true;
    });

    final result = await ref
        .read(authProvider.notifier)
        .resetPassword(
          token: _resetToken ?? '',
          newPassword: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result) {
      _showSnack('Password updated — sign in with your new password');
      context.pop();
    } else {
      _showSnack(ref.read(authProvider).error ?? 'Could not reset password');
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF16241C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const CgMountainBackground(),
          SafeArea(
            bottom: false,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CgRoundButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        iconSize: 18,
                        semanticLabel: 'Back',
                        onTap: _goBackStep,
                        color: Colors.white,
                        background: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0.14),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reset Password',
                              style: CgType.pageTitle.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Step $_step of 3',
                              style: CgType.b14.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      for (var i = 1; i <= 3; i++) ...[
                        _StepDot(number: i, active: _step >= i),
                        if (i < 3)
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              color: _step > i ? c.primary : c.line,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CgGlassPanel(
                    radius: BorderRadius.circular(CgRadii.card),
                    padding: const EdgeInsets.all(20),
                    minHeight: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_step == 1) _buildEmailStep(),
                        if (_step == 2) _buildCodeStep(),
                        if (_step == 3) _buildPasswordStep(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(String title, String subtitle) {
    final c = CgColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CgType.h1Bold.copyWith(fontSize: 24, color: c.text)),
        const SizedBox(height: 6),
        Text(subtitle, style: CgType.b14.copyWith(color: c.text2)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmailStep() {
    final c = CgColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle(
          'Forgot Password',
          "Enter your email and we'll send you a 6-digit code",
        ),
        CgTextField(
          label: 'Email',
          controller: _emailController,
          icon: Icons.email_outlined,
          hint: 'Enter your email',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) => _requestCode(),
        ),
        const SizedBox(height: 20),
        CgPillButton(
          onTap: _requestCode,
          loading: _isLoading,
          child: const Text('Send Code'),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text.rich(
            TextSpan(
              text: 'Remember your password? ',
              style: CgType.b14.copyWith(color: c.text2),
              children: [
                TextSpan(
                  text: 'Sign In',
                  style: CgType.b14.copyWith(
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    final c = CgColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle(
          'Enter the Code',
          'We sent a 6-digit code to ${_emailController.text.trim()}.\n'
              'It expires in 10 minutes.',
        ),
        if (_devCode != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.mint,
              borderRadius: BorderRadius.circular(CgRadii.input),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_mode_rounded, size: 20, color: c.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Development code: $_devCode',
                    style: CgType.l12.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.text,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _codeController.text = _devCode!;
                    setState(() => _codeError = null);
                  },
                  style: TextButton.styleFrom(foregroundColor: c.primary),
                  child: const Text('Use it'),
                ),
              ],
            ),
          ),
        ],
        CgTextField(
          label: 'Code',
          controller: _codeController,
          icon: Icons.pin_rounded,
          hint: '6-digit code',
          errorText: _codeError,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) => _verifyCode(),
        ),
        const SizedBox(height: 20),
        CgPillButton(
          onTap: _verifyCode,
          loading: _isLoading,
          child: const Text('Verify Code'),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _resendCode,
            style: TextButton.styleFrom(foregroundColor: c.primary),
            child: const Text("Didn't receive it? Resend code"),
          ),
        ),
      ],
    );
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);
    final ok = await ref
        .read(authProvider.notifier)
        .requestCode(email: _emailController.text.trim());
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (ok) {
        _devCode = ref.read(authProvider.notifier).lastResetCode;
        _codeController.clear();
      }
    });
    _showSnack(ok ? 'A new code was sent' : 'Could not send a new code');
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStepTitle(
          'New Password',
          'Choose a strong password for your account',
        ),
        CgTextField(
          label: 'New password',
          controller: _passwordController,
          icon: Icons.lock_outline_rounded,
          hint: 'New password',
          errorText: _passwordError,
          obscure: true,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 12),
        CgTextField(
          label: 'Confirm password',
          controller: _confirmController,
          icon: Icons.lock_outline_rounded,
          hint: 'Confirm new password',
          errorText: _confirmError,
          obscure: true,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 20),
        CgPillButton(
          onTap: _setPassword,
          loading: _isLoading,
          child: const Text('Set New Password'),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.active});

  final int number;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: active ? c.gMain : null,
        color: active ? null : c.line,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$number',
        style: CgType.l12.copyWith(
          fontWeight: FontWeight.w800,
          color: active ? c.onPrimary : c.text2,
        ),
      ),
    );
  }
}

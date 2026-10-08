import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';

/// Forgot password — 3-step flow matching the spec:
///   1. enter email → 6-digit code is issued
///   2. verify the 6-digit code
///   3. set a new password
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

  final _emailFormKey = GlobalKey<FormState>();
  final _codeFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _resetToken;
  String? _devCode; // shown only when the backend echoes it (no email provider)
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 13)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // ── Step 1: request code ────────────────────────────────────────────────

  Future<void> _requestCode() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref
        .read(authProvider.notifier)
        .requestCode(email: _emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result) {
        _step = 2;
        _devCode = ref.read(authProvider.notifier).lastResetCode;
      }
    });
    if (!result) {
      _showSnack(
        ref.read(authProvider).error ?? 'Could not send the code',
      );
    }
  }

  // ── Step 2: verify code ─────────────────────────────────────────────────

  Future<void> _verifyCode() async {
    if (!_codeFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref.read(authProvider.notifier).verifyResetCode(
          email: _emailController.text.trim(),
          code: _codeController.text.trim(),
        );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result) {
        _step = 3;
        _resetToken = ref.read(authProvider.notifier).lastResetToken;
      }
    });
    if (!result) {
      _showSnack(
        ref.read(authProvider).error ?? 'Invalid or expired code',
      );
    }
  }

  // ── Step 3: set new password ────────────────────────────────────────────

  String? _validatePassword(String? v) {
    final value = v ?? '';
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) return 'Add a letter';
    if (!RegExp(r'\d').hasMatch(value)) return 'Add a number';
    return null;
  }

  Future<void> _setPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref.read(authProvider.notifier).resetPassword(
          token: _resetToken ?? '',
          newPassword: _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result) {
      _showSnack('Password updated — sign in with your new password');
      context.pop();
    } else {
      _showSnack(
        ref.read(authProvider).error ?? 'Could not reset password',
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _step > 1
              ? () => setState(() => _step -= 1)
              : () => context.pop(),
        ),
        title: const Text('Reset Password'),
      ),
      body: NatureBackground.wrap(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: OneUISpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: OneUISpacing.lg),
                _buildStepIndicator(),
                const SizedBox(height: OneUISpacing.xxl),
                if (_step == 1) _buildEmailStep(),
                if (_step == 2) _buildCodeStep(),
                if (_step == 3) _buildPasswordStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    Widget dot(int number) {
      final active = _step >= number;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? AppColors.primary(context) : AppColors.divider(context),
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.textHint(context),
            ),
          ),
        ),
      );
    }

    Widget line(bool done) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: done
                ? AppColors.primary(context)
                : AppColors.divider(context),
          ),
        );

    return Row(
      children: [
        dot(1),
        line(_step > 1),
        dot(2),
        line(_step > 2),
        dot(3),
      ],
    );
  }

  Widget _buildTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: OneUISpacing.sm),
        Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: OneUISpacing.xxl),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Forgot Password',
          'Enter your email and we\'ll send you a 6-digit code',
        ),
        Form(
          key: _emailFormKey,
          child: GlassInput(
            controller: _emailController,
            hintText: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Enter your email';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
        ),
        const SizedBox(height: OneUISpacing.xxl),
        CGButton(
          label: 'Send Code',
          isLoading: _isLoading,
          onPressed: _requestCode,
        ),
        const SizedBox(height: OneUISpacing.xxl),
        Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Text.rich(
              TextSpan(
                text: 'Remember your password? ',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary(context),
                ),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: OneUISpacing.xxl),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(
          'Enter the Code',
          'We sent a 6-digit code to ${_emailController.text.trim()}.\n'
              'It expires in 10 minutes.',
        ),
        if (_devCode != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: OneUISpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_mode_rounded,
                    size: 20, color: AppColors.primary(context)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Development code: $_devCode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _codeController.text = _devCode!;
                  },
                  child: const Text('Use it'),
                ),
              ],
            ),
          ),
        ],
        Form(
          key: _codeFormKey,
          child: GlassInput(
            controller: _codeController,
            hintText: '6-digit code',
            prefixIcon: Icons.pin_rounded,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            validator: (v) {
              final value = (v ?? '').trim();
              if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'Enter the 6-digit code';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: OneUISpacing.xxl),
        CGButton(
          label: 'Verify Code',
          isLoading: _isLoading,
          onPressed: _verifyCode,
        ),
        const SizedBox(height: OneUISpacing.md),
        Center(
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    final ok = await ref
                        .read(authProvider.notifier)
                        .requestCode(email: _emailController.text.trim());
                    if (!mounted) return;
                    setState(() {
                      _isLoading = false;
                      if (ok) {
                        _devCode =
                            ref.read(authProvider.notifier).lastResetCode;
                        _codeController.clear();
                      }
                    });
                    _showSnack(ok ? 'A new code was sent' : 'Could not send a new code');
                  },
            child: Text(
              'Didn\'t receive it? Resend code',
              style: TextStyle(fontSize: 14, color: AppColors.primary(context)),
            ),
          ),
        ),
        const SizedBox(height: OneUISpacing.lg),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('New Password', 'Choose a strong password for your account'),
        Form(
          key: _passwordFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassInput(
                controller: _passwordController,
                hintText: 'New password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: OneUISpacing.md),
              GlassInput(
                controller: _confirmController,
                hintText: 'Confirm new password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                validator: (v) {
                  if ((v ?? '') != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: OneUISpacing.xxl),
        CGButton(
          label: 'Set New Password',
          isLoading: _isLoading,
          onPressed: _setPassword,
        ),
        const SizedBox(height: OneUISpacing.xxl),
      ],
    );
  }
}

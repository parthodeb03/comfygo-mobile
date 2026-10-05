import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  String _selectedMethod = 'email';
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _selectedMethod == 'email'
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    final success = await ref
        .read(authProvider.notifier)
        .forgotPassword(email: email);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isSent = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: OneUISpacing.lg),
          child: _isSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: OneUISpacing.lg),

        // Title
        const Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: OneUIColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: OneUISpacing.sm),
        Text(
          'Choose how you want to reset your password',
          style: TextStyle(fontSize: 14, color: OneUIColors.textSecondaryLight),
        ),

        const SizedBox(height: OneUISpacing.xxl),

        // Option cards
        _buildOptionCard(
          icon: Icons.email_outlined,
          title: 'Reset via Email',
          subtitle: 'We\'ll send a reset link to your email',
          isSelected: _selectedMethod == 'email',
          onTap: () => setState(() => _selectedMethod = 'email'),
        ),

        const SizedBox(height: OneUISpacing.md),

        _buildOptionCard(
          icon: Icons.phone_outlined,
          title: 'Reset via Phone',
          subtitle: 'We\'ll send an OTP to your phone number',
          isSelected: _selectedMethod == 'phone',
          onTap: () => setState(() => _selectedMethod = 'phone'),
        ),

        const SizedBox(height: OneUISpacing.xxl),

        // Input field
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(
                _selectedMethod == 'email' ? 'Email address' : 'Phone number',
              ),
              const SizedBox(height: OneUISpacing.sm),
              GlassInput(
                controller: _selectedMethod == 'email'
                    ? _emailController
                    : _phoneController,
                hintText: _selectedMethod == 'email'
                    ? 'Enter your email'
                    : 'Enter your phone number',
                prefixIcon: _selectedMethod == 'email'
                    ? Icons.email_outlined
                    : Icons.phone_outlined,
                keyboardType: _selectedMethod == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return _selectedMethod == 'email'
                        ? 'Enter your email'
                        : 'Enter your phone number';
                  }
                  if (_selectedMethod == 'email' && !v.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: OneUISpacing.xxl),

        // Send button
        CGButton(
          label: 'Send Reset Link',
          isLoading: _isLoading,
          onPressed: _handleSend,
        ),

        const SizedBox(height: OneUISpacing.xxl),

        // Back to login
        Center(
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Text.rich(
              TextSpan(
                text: 'Remember your password? ',
                style: TextStyle(
                  fontSize: 14,
                  color: OneUIColors.textSecondaryLight,
                ),
                children: const [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: OneUIColors.primaryLight,
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

  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: OneUISpacing.massive),

        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: OneUIColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: OneUIColors.primaryLight,
          ),
        ),

        const SizedBox(height: OneUISpacing.xxl),

        const Text(
          'Check Your Email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: OneUIColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: OneUISpacing.sm),
        Text(
          'We\'ve sent a password reset link to\n${_selectedMethod == "email" ? _emailController.text : _phoneController.text}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: OneUIColors.textSecondaryLight),
        ),

        const SizedBox(height: OneUISpacing.xxl),

        CGButton(label: 'Back to Sign In', onPressed: () => context.pop()),

        const SizedBox(height: OneUISpacing.lg),

        TextButton(
          onPressed: () {
            setState(() {
              _isSent = false;
              _selectedMethod = 'email';
            });
          },
          child: const Text(
            'Didn\'t receive it? Try again',
            style: TextStyle(fontSize: 14, color: OneUIColors.primaryLight),
          ),
        ),

        const SizedBox(height: OneUISpacing.xxl),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(OneUISpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? OneUIColors.primarySoft
              : OneUIColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? OneUIColors.primaryLight
                : OneUIColors.dividerLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? OneUIColors.primaryLight
                    : OneUIColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.white
                    : OneUIColors.textSecondaryLight,
              ),
            ),
            const SizedBox(width: OneUISpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? OneUIColors.primaryVariantLight
                          : OneUIColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: OneUIColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 22,
              color: isSelected
                  ? OneUIColors.primaryLight
                  : OneUIColors.textHintLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: OneUIColors.textSecondaryLight,
        ),
      ),
    );
  }
}

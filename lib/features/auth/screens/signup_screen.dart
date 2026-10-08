import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'tourist';

  final Map<String, String> _roles = {
    'tourist': 'Tourist',
    'guide': 'Guide',
    'hotel_manager': 'Hotel Manager',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ref
        .read(authProvider.notifier)
        .register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: _selectedRole,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/');
    } else {
      final error = ref.read(authProvider).error;
      if (mounted && error != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(fontSize: 13)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: NatureBackground.wrap(child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: OneUISpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                 Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: OneUISpacing.sm),
                Text(
                  'Start your journey with ComfyGo',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),

                const SizedBox(height: OneUISpacing.xxl),

                // Role selector — pill/segmented tabs
                _buildLabel('I am a'),
                const SizedBox(height: OneUISpacing.sm),
                _buildRoleSelector(),

                const SizedBox(height: OneUISpacing.xxl),

                // Full Name
                _buildLabel('Full Name'),
                const SizedBox(height: OneUISpacing.sm),
                GlassInput(
                  controller: _nameController,
                  hintText: 'Enter your full name',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your name';
                    return null;
                  },
                ),

                const SizedBox(height: OneUISpacing.lg),

                // Email
                _buildLabel('Email address'),
                const SizedBox(height: OneUISpacing.sm),
                GlassInput(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your email';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),

                const SizedBox(height: OneUISpacing.lg),

                // Phone
                _buildLabel('Phone number'),
                const SizedBox(height: OneUISpacing.sm),
                GlassInput(
                  controller: _phoneController,
                  hintText: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your phone';
                    return null;
                  },
                ),

                const SizedBox(height: OneUISpacing.lg),

                // Password
                _buildLabel('Password'),
                const SizedBox(height: OneUISpacing.sm),
                GlassInput(
                  controller: _passwordController,
                  hintText: 'Create a password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.textSecondary(context),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: OneUISpacing.xxl),

                // Register button
                CGButton(
                  label: 'Register',
                  isLoading: _isLoading,
                  onPressed: _handleSignup,
                ),

                const SizedBox(height: OneUISpacing.xxl),

                // Terms text
                Text.rich(
                  TextSpan(
                    text: 'By registering, you agree to our ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
                    ),
                    children:  [
                      TextSpan(
                        text: 'Terms of Service',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/terms'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push('/privacy'),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: OneUISpacing.xxl),

                // Sign in link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child:  Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: OneUISpacing.xxl),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: _roles.entries.map((entry) {
          final isSelected = _selectedRole == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style:  TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

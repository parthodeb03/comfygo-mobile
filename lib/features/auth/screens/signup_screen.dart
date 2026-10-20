import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';
import '../widgets/auth_shell.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'tourist';
  bool _terms = false;
  bool _loading = false;

  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _termsError;
  String? _apiError;

  static const _roles = <String, String>{
    'tourist': 'Tourist',
    'guide': 'Guide',
    'hotel_manager': 'Hotel manager',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (_loading) return;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'[\s-]'), '');
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nameError = name.length < 2 ? 'Enter your full name' : null;
      _phoneError = RegExp(r'^(\+?880|0)1[3-9]\d{8}$').hasMatch(phone)
          ? null
          : 'Enter a valid Bangladesh mobile number';
      _emailError = RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)
          ? null
          : 'Enter a valid email address';
      _passwordError = password.length < 6 ? 'Use at least 6 characters' : null;
      _termsError = _terms ? null : 'Please accept the terms to continue';
      _apiError = null;
    });

    if (_nameError != null ||
        _phoneError != null ||
        _emailError != null ||
        _passwordError != null ||
        _termsError != null) {
      return;
    }

    setState(() => _loading = true);

    final success = await ref
        .read(authProvider.notifier)
        .register(
          email: email,
          password: password,
          fullName: name,
          phone: phone,
          role: _role,
        );

    if (!mounted) return;
    if (success) {
      context.go('/');
      return;
    }

    setState(() {
      _loading = false;
      _apiError =
          ref.read(authProvider).error ?? 'Unable to create your account';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgAuthShell(
      title: 'Create account',
      subtitle: 'Join ComfyGo and explore Bangladesh',
      onBack: () => context.go('/intro'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CgTextField(
            label: 'Full name',
            controller: _nameController,
            icon: Icons.person_outline_rounded,
            hint: 'Your full name',
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.name],
            errorText: _nameError,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 16),
          CgTextField(
            label: 'Mobile number',
            controller: _phoneController,
            icon: Icons.phone_outlined,
            hint: '+880 1XXX-XXXXXX',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.telephoneNumber],
            errorText: _phoneError,
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          const SizedBox(height: 16),
          CgTextField(
            label: 'Email address',
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.email],
            errorText: _emailError,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
          ),
          const SizedBox(height: 16),
          CgTextField(
            label: 'Password',
            controller: _passwordController,
            icon: Icons.lock_outline_rounded,
            hint: 'At least 6 characters',
            obscure: true,
            textInputAction: TextInputAction.done,
            enabled: !_loading,
            autofillHints: const [AutofillHints.newPassword],
            errorText: _passwordError,
            onSubmitted: (_) => _createAccount(),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'I am a',
            style: CgType.l12.copyWith(
              color: c.text,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final entry in _roles.entries) ...[
                Expanded(
                  child: _RoleButton(
                    label: entry.value,
                    selected: _role == entry.key,
                    onTap: _loading
                        ? null
                        : () => setState(() => _role = entry.key),
                  ),
                ),
                if (entry.key != _roles.keys.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _loading
                ? null
                : () {
                    setState(() {
                      _terms = !_terms;
                      if (_terms) _termsError = null;
                    });
                  },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: _terms ? c.primary : c.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _terms ? c.primary : c.line,
                      width: 1.5,
                    ),
                  ),
                  child: _terms
                      ? Icon(Icons.check, size: 14, color: c.onPrimary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms',
                          style: CgType.b14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: CgType.b14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: c.text,
                          ),
                        ),
                      ],
                    ),
                    style: CgType.b14.copyWith(color: c.text2),
                  ),
                ),
              ],
            ),
          ),
          if (_termsError != null) ...[
            const SizedBox(height: 6),
            Text(
              _termsError!,
              style: CgType.l12.copyWith(color: CgColorConstants.danger),
            ),
          ],
          if (_apiError != null) ...[
            const SizedBox(height: 12),
            Text(
              _apiError!,
              style: CgType.l12.copyWith(
                color: CgColorConstants.danger,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 20),
          CgPillButton(
            width: double.infinity,
            loading: _loading,
            onTap: _createAccount,
            semanticLabel: 'Create account',
            child: const Text('Create account'),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: CgType.b14.copyWith(color: c.text2),
              ),
              GestureDetector(
                onTap: _loading ? null : () => context.go('/login'),
                child: Text(
                  'Sign in',
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

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? c.primary : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? c.primary : c.line, width: 1.5),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CgType.l12.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? c.onPrimary : c.text2,
          ),
        ),
      ),
    );
  }
}

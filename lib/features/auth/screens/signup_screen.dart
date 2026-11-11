// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Sign-up screen in the reference visual language; validation and registration
// are the Phase 2 work it wraps.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../state/auth_provider.dart';
import '../widgets/reference_auth_page.dart';
import '../widgets/reference_controls.dart';
import '../widgets/reference_theme.dart';

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
    final c = CgRefColors.of(context);
    return CgAuthPage(
      title: 'Create account',
      onBack: () => context.go('/welcome'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _RefLabel(text: 'Full name'),
          const SizedBox(height: 8),
          CgRefField(
            controller: _nameController,
            hint: 'Your full name',
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.name],
            error: _nameError != null,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          if (_nameError != null) ...[
            const SizedBox(height: 6),
            CgRefError(message: _nameError!),
          ],
          const SizedBox(height: 16),
          const _RefLabel(text: 'Mobile number'),
          const SizedBox(height: 8),
          CgRefField(
            controller: _phoneController,
            hint: '+880 1XXX-XXXXXX',
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.telephoneNumber],
            error: _phoneError != null,
            onChanged: (_) {
              if (_phoneError != null) setState(() => _phoneError = null);
            },
          ),
          if (_phoneError != null) ...[
            const SizedBox(height: 6),
            CgRefError(message: _phoneError!),
          ],
          const SizedBox(height: 16),
          const _RefLabel(text: 'Email address'),
          const SizedBox(height: 8),
          CgRefField(
            controller: _emailController,
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_loading,
            autofillHints: const [AutofillHints.email],
            error: _emailError != null,
            onChanged: (_) {
              if (_emailError != null) setState(() => _emailError = null);
            },
          ),
          if (_emailError != null) ...[
            const SizedBox(height: 6),
            CgRefError(message: _emailError!),
          ],
          const SizedBox(height: 16),
          const _RefLabel(text: 'Password'),
          const SizedBox(height: 8),
          CgRefField(
            controller: _passwordController,
            hint: 'At least 6 characters',
            obscure: true,
            textInputAction: TextInputAction.done,
            enabled: !_loading,
            autofillHints: const [AutofillHints.newPassword],
            error: _passwordError != null,
            onSubmitted: (_) => _createAccount(),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
          ),
          if (_passwordError != null) ...[
            const SizedBox(height: 6),
            CgRefError(message: _passwordError!),
          ],
          const SizedBox(height: 20),
          const _RefLabel(text: 'I am a'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _roles.entries)
                CgRefChip(
                  label: entry.value,
                  selected: _role == entry.key,
                  onTap: _loading
                      ? null
                      : () => setState(() => _role = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            checked: _terms,
            child: GestureDetector(
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
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: _terms ? c.primary : c.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _terms ? c.primary : c.outline,
                        width: 1.5,
                      ),
                    ),
                    child: _terms
                        ? Icon(Icons.check, size: 14, color: c.surface)
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
                            style: CgRefType.bodyS.copyWith(
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: CgRefType.bodyS.copyWith(
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                        ],
                      ),
                      style: CgRefType.bodyS.copyWith(color: c.text2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_termsError != null) ...[
            const SizedBox(height: 8),
            CgRefError(message: _termsError!),
          ],
          if (_apiError != null) ...[
            const SizedBox(height: 12),
            CgRefError(message: _apiError!),
          ],
          const SizedBox(height: 20),
          CgRefButton(
            expand: true,
            loading: _loading,
            onTap: _createAccount,
            semanticLabel: 'Create account',
            child: const Text('Create account'),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: CgRefType.bodyS.copyWith(color: c.text2),
              ),
              CgRefLink(
                label: 'Sign in',
                color: c.primary,
                minHeight: 28,
                onTap: _loading ? null : () => context.go('/login'),
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

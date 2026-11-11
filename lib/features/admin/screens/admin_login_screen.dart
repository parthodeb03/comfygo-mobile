// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';

/// Dedicated admin sign-in, backed by `POST /api/v1/admin/login`.
///
/// Reachable from the login screen (tap the logo 5 times).
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)
          ? 'Enter a valid email'
          : null;
      _passwordError = password.isEmpty ? 'Enter your password' : null;
      _error = null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isLoading = true);
    final success = await ref
        .read(authProvider.notifier)
        .adminLogin(email: email, password: password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/admin');
    } else {
      setState(() {
        _error = ref.read(authProvider).error ?? 'Unable to sign in';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Administrator',
            subtitle: 'Sign in to manage ComfyGo',
            onBack: () => goBack(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: c.gMain,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 36,
                      color: c.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CgTextField(
                    key: const Key('admin-email'),
                    label: 'Email address',
                    controller: _emailController,
                    icon: Icons.mail_outline_rounded,
                    hint: 'admin@comfygo.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    errorText: _emailError,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CgTextField(
                    key: const Key('admin-password'),
                    label: 'Password',
                    controller: _passwordController,
                    icon: Icons.lock_outline_rounded,
                    hint: 'Enter your password',
                    obscure: true,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    errorText: _passwordError,
                    onSubmitted: (_) => _handleLogin(),
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: CgType.l12.copyWith(
                        color: CgColorConstants.danger,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  CgPillButton(
                    key: const Key('admin-sign-in'),
                    width: double.infinity,
                    loading: _isLoading,
                    onTap: _handleLogin,
                    child: const Text('Sign In'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

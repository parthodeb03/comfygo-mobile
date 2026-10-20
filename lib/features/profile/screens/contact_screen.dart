import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';

/// Contact form — messages are saved to the database and shown in the
/// admin's inbox (`GET /api/v1/contact/inbox`).
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;
  String? _nameError;
  String? _emailError;
  String? _messageError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Enter your name' : null;
      _emailError = !RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)
          ? 'Enter a valid email'
          : null;
      _messageError = message.length < 10
          ? 'Tell us a bit more (at least 10 characters)'
          : null;
    });
    if (_nameError != null || _emailError != null || _messageError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.post(
        '/api/v1/contact',
        data: {'name': name, 'email': email, 'message': message},
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLoading = false;
          _sent = true;
        });
      } else {
        setState(() => _isLoading = false);
        showCgToast(context, 'Could not send your message. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showCgToast(
        context,
        'Connection error. Please check your network and retry.',
      );
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
            title: 'Contact Us',
            subtitle:
                'Send us a message and our team will get back to you '
                'within 24 hours.',
            onBack: () => goBack(context),
          ),
          const SizedBox(height: 20),
          if (_sent)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CgCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: c.gMint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outline_rounded,
                        size: 40,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Message Sent',
                      style: CgType.t20.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thanks for reaching out. We\'ll reply to\n'
                      '${_emailController.text.trim()} soon.',
                      textAlign: TextAlign.center,
                      style: CgType.b14.copyWith(color: c.text2),
                    ),
                    const SizedBox(height: 20),
                    CgPillButton(
                      width: double.infinity,
                      onTap: () => setState(() {
                        _sent = false;
                        _messageController.clear();
                      }),
                      child: const Text('Send Another'),
                    ),
                    const SizedBox(height: 12),
                    CgOutlineButton(
                      width: double.infinity,
                      onTap: () => goBack(context),
                      child: const Text('Back to Profile'),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CgTextField(
                    label: 'Your name',
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    hint: 'Full name',
                    enabled: !_isLoading,
                    errorText: _nameError,
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  CgTextField(
                    label: 'Your email',
                    controller: _emailController,
                    icon: Icons.mail_outline_rounded,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
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
                    label: 'Your message',
                    controller: _messageController,
                    icon: Icons.mode_comment_outlined,
                    hint: 'How can we help?',
                    maxLines: 5,
                    enabled: !_isLoading,
                    errorText: _messageError,
                    onChanged: (_) {
                      if (_messageError != null) {
                        setState(() => _messageError = null);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  CgPillButton(
                    width: double.infinity,
                    loading: _isLoading,
                    onTap: _submit,
                    child: const Text('Send Message'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

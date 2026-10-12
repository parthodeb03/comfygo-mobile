import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';

/// Contact form — messages are saved to the database and shown in the
/// admin's inbox (`GET /api/v1/contact/inbox`).
class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with the signed-in user's name/email when available
    _nameController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final dio = ref.read(apiClientProvider).dio;
      final response = await dio.post(
        '/api/v1/contact',
        data: {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLoading = false;
          _sent = true;
        });
      } else {
        setState(() => _isLoading = false);
        _showSnack('Could not send your message. Please try again.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Connection error. Please check your network and retry.');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => goBack(context),
        ),
        title: const Text('Contact Us'),
      ),
      body: NatureBackground.wrap(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(OneUISpacing.lg),
            child: _sent ? _buildSentView() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How can we help?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: OneUISpacing.sm),
          Text(
            'Send us a message and our team will get back to you within 24 hours.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: OneUISpacing.xxl),
          GlassInput(
            controller: _nameController,
            hintText: 'Your name',
            prefixIcon: Icons.person_outline_rounded,
            enabled: !_isLoading,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: OneUISpacing.md),
          GlassInput(
            controller: _emailController,
            hintText: 'Your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return 'Enter your email';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: OneUISpacing.md),
          GlassInput(
            controller: _messageController,
            hintText: 'Your message',
            prefixIcon: Icons.message_outlined,
            maxLines: 5,
            enabled: !_isLoading,
            validator: (v) => (v ?? '').trim().length < 10
                ? 'Tell us a bit more (at least 10 characters)'
                : null,
          ),
          const SizedBox(height: OneUISpacing.xxl),
          CGButton(
            label: 'Send Message',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
          const SizedBox(height: OneUISpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSentView() {
    return Column(
      children: [
        const SizedBox(height: OneUISpacing.massive),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primarySoft(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 40,
            color: AppColors.primary(context),
          ),
        ),
        const SizedBox(height: OneUISpacing.xxl),
        Text(
          'Message Sent',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: OneUISpacing.sm),
        Text(
          'Thanks for reaching out. We\'ll reply to\n${_emailController.text.trim()} soon.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
        ),
        const SizedBox(height: OneUISpacing.xxl),
        CGButton(
          label: 'Send Another',
          onPressed: () => setState(() {
            _sent = false;
            _messageController.clear();
          }),
        ),
        const SizedBox(height: OneUISpacing.md),
        TextButton(
          onPressed: () => goBack(context),
          child: Text(
            'Back to Profile',
            style: TextStyle(fontSize: 14, color: AppColors.primary(context)),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/auth_provider.dart';

/// Functional profile editor — saves through PUT /auth/profile and
/// refreshes the signed-in user everywhere in the app.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _nationality;
  late final TextEditingController _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _nationality = TextEditingController(text: user?.nationality ?? '');
    _image = TextEditingController(text: user?.profileImage ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _nationality.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;
    setState(() => _saving = true);

    final ok = await ref.read(authProvider.notifier).updateProfile({
      'full_name': _name.text.trim(),
      'phone': _phone.text.trim(),
      'nationality': _nationality.text.trim(),
      if (_image.text.trim().isNotEmpty)
        'profile_image': _image.text.trim(),
    });

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: Color(0xFF1B7A4F),
        ),
      );
      context.pop();
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Could not update the profile.'),
          backgroundColor: const Color(0xFFB3261E),
        ),
      );
    }
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, size: 20),
    filled: true,
    fillColor: AppColors.surfaceVariant(context),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.primary(context), width: 1.6),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Profile'),
      ),
      body: NatureBackground.wrap(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    user?.email ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoration('Full name', Icons.person_rounded),
                    validator: (v) =>
                        (v == null || v.trim().length < 2)
                        ? 'Please enter your full name'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: _decoration(
                      'Phone number',
                      Icons.phone_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nationality,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoration(
                      'Nationality',
                      Icons.public_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _image,
                    keyboardType: TextInputType.url,
                    decoration: _decoration(
                      'Profile photo URL (optional)',
                      Icons.photo_camera_rounded,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CGButton(
                    key: const Key('save-profile'),
                    label: 'Save Changes',
                    icon: Icons.check_rounded,
                    isLoading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

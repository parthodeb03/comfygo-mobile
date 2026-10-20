import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';

/// Functional profile editor — saves through PUT /auth/profile and
/// refreshes the signed-in user everywhere in the app.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _nationality;
  late final TextEditingController _image;
  bool _saving = false;
  String? _nameError;

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
    if (_saving) return;
    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _nameError = 'Please enter your full name');
      return;
    }

    setState(() => _saving = true);

    final ok = await ref.read(authProvider.notifier).updateProfile({
      'full_name': name,
      'phone': _phone.text.trim(),
      'nationality': _nationality.text.trim(),
      if (_image.text.trim().isNotEmpty) 'profile_image': _image.text.trim(),
    });

    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      showCgToast(context, 'Profile updated successfully.');
      context.pop();
    } else {
      showCgToast(
        context,
        ref.read(authProvider).error ?? 'Could not update the profile.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return CgPageScaffold(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Edit Profile',
            subtitle: user?.email ?? '',
            onBack: () => goBack(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CgTextField(
                  label: 'Full name',
                  controller: _name,
                  icon: Icons.person_outline_rounded,
                  hint: 'Your full name',
                  enabled: !_saving,
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) {
                      setState(() => _nameError = null);
                    }
                  },
                ),
                const SizedBox(height: 16),
                CgTextField(
                  label: 'Phone number',
                  controller: _phone,
                  icon: Icons.phone_outlined,
                  hint: '+880 1XXX-XXXXXX',
                  keyboardType: TextInputType.phone,
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                CgTextField(
                  label: 'Nationality',
                  controller: _nationality,
                  icon: Icons.public_rounded,
                  hint: 'Bangladeshi',
                  enabled: !_saving,
                ),
                const SizedBox(height: 16),
                CgTextField(
                  label: 'Profile photo URL (optional)',
                  controller: _image,
                  icon: Icons.photo_camera_outlined,
                  hint: 'https://…',
                  keyboardType: TextInputType.url,
                  enabled: !_saving,
                ),
                const SizedBox(height: 24),
                CgPillButton(
                  key: const Key('save-profile'),
                  width: double.infinity,
                  loading: _saving,
                  onTap: _saving ? null : _save,
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

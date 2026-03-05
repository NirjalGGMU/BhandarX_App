import 'dart:io';

import 'package:bhandarx_flutter/app/themes/app_colors.dart';
import 'package:bhandarx_flutter/core/widgets/custom_button.dart';
import 'package:bhandarx_flutter/core/widgets/input_field.dart';
import 'package:bhandarx_flutter/core/config/app_config.dart';
import 'package:bhandarx_flutter/core/localization/app_localizations.dart';
import 'package:bhandarx_flutter/core/services/permissions/media_permission_service.dart';
import 'package:bhandarx_flutter/features/auth/presentation/state/auth_state.dart';
import 'package:bhandarx_flutter/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const routeName = '/profile/edit';
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _phoneCtrl;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).entity;
    _nameCtrl = TextEditingController(text: user?.fullName ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _usernameCtrl = TextEditingController(text: user?.username ?? '');
    _phoneCtrl = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.entity;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                _EditableProfileAvatar(
                  selectedImage: _selectedImage,
                  remoteImagePath: user?.profilePicture,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: IconButton.filled(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InputField(label: 'Full name', controller: _nameCtrl),
          InputField(
            label: 'Email',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          InputField(label: 'Username', controller: _usernameCtrl),
          InputField(
            label: 'Phone',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Save changes',
            isLoading: authState.status == AuthStatus.loading,
            onPressed: () async {
              if (_selectedImage != null) {
                final imageUploaded = await ref
                    .read(authViewModelProvider.notifier)
                    .uploadProfileImage(_selectedImage!);
                if (!mounted) {
                  return;
                }
                if (!imageUploaded) {
                  final error = ref.read(authViewModelProvider).errorMessage;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Unable to upload profile image'),
                    ),
                  );
                  return;
                }
              }

              final success =
                  await ref.read(authViewModelProvider.notifier).updateProfile(
                        fullName: _nameCtrl.text.trim(),
                        email: _emailCtrl.text.trim(),
                        username: _usernameCtrl.text.trim(),
                        phoneNumber: _phoneCtrl.text.trim().isEmpty
                            ? null
                            : _phoneCtrl.text.trim(),
                      );
              if (!mounted) {
                return;
              }
              if (success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
                navigator.pop();
              } else {
                final error = ref.read(authViewModelProvider).errorMessage;
                messenger.showSnackBar(
                  SnackBar(content: Text(error ?? 'Unable to update profile')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!mounted) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(l10n?.tr('take_photo') ?? 'Take photo'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _pickImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(
                  l10n?.tr('choose_from_gallery') ?? 'Choose from gallery',
                ),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await _pickImageFromSource(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final pageContext = context;
    late final bool hasPermission;
    if (source == ImageSource.camera) {
      // ignore: use_build_context_synchronously
      hasPermission =
          await MediaPermissionService.requestCameraPermission(pageContext);
    } else {
      // ignore: use_build_context_synchronously
      hasPermission =
          await MediaPermissionService.requestPhotoPermission(pageContext);
    }
    if (!hasPermission) {
      return;
    }

    final picker = ImagePicker();
    final file = await picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1200);
    if (file == null) {
      return;
    }
    setState(() {
      _selectedImage = File(file.path);
    });
  }
}

class _EditableProfileAvatar extends StatelessWidget {
  final File? selectedImage;
  final String? remoteImagePath;

  const _EditableProfileAvatar({
    required this.selectedImage,
    required this.remoteImagePath,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (selectedImage != null) {
      child = ClipOval(
        child: Image.file(
          selectedImage!,
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      );
    } else {
      final imageUrl = AppConfig.resolveMediaUrl(remoteImagePath);
      child = imageUrl.isEmpty
          ? const Icon(Icons.person, color: Colors.white, size: 40)
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
    }

    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.primary,
      child: child,
    );
  }
}

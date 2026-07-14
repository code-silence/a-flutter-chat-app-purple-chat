import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_providers.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../../../core/providers/imgbb_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked == null) return;

    final compressed = await FlutterImageCompress.compressAndGetFile(
      picked.path,
      '${picked.path}_compressed.jpg',
      quality: 75,
    );

    if (compressed == null) return;

    setState(() {
      _image = File(compressed.path);
    });
  }

  bool _loaded = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: FutureBuilder<UserModel?>(
        future: repository.getCurrentUserModel(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          if (!_loaded) {
            _displayNameController.text = user.displayName;
            _bioController.text = user.bio;
            _loaded = true;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (user.photoUrl.isNotEmpty
                                      ? NetworkImage(user.photoUrl)
                                      : null)
                                  as ImageProvider?,
                        child: (_image == null && user.photoUrl.isEmpty)
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),

                      TextButton(
                        onPressed: _pickImage,
                        child: const Text('Change Photo'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                TextField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Bio'),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () async {
                    await repository.updateProfile(
                      displayName: _displayNameController.text,
                      bio: _bioController.text,
                    );
                    if (_image != null) {
                      final result = await ref
                          .read(imgbbServiceProvider)
                          .upload(_image!);

                      await repository.updatePhoto(
                        photoUrl: result['photoUrl'],
                        photoDeleteUrl: result['deleteUrl'],
                      );
                    }

                    if (!mounted) return;

                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

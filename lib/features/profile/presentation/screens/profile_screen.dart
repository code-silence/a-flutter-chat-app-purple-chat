import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/models/user_model.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../routes/route_names.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final repository = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<UserModel?>(
        future: ref.watch(authRepositoryProvider).getCurrentUserModel(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!;

          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text('@${user.username}'),

                  const SizedBox(height: 12),

                  Text(user.bio),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      await context.push(RouteNames.editProfile);

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../../routes/route_names.dart';
import 'package:go_router/go_router.dart';


class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text('Change Password'),
            onTap: () async {
              final email = ref.read(authRepositoryProvider).currentUser?.email;

              if (email == null) return;

              await ref
                  .read(authRepositoryProvider)
                  .sendPasswordResetEmail(email: email);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password reset email sent.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mark_email_read),
            title: const Text('Resend Verification Email'),
            onTap: () async {
              await ref.read(authRepositoryProvider).resendVerificationEmail();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification email sent.')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Users'),
            onTap: () {
              context.push(RouteNames.blockedUsers);
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About PurpleChat'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/providers/auth_providers.dart';
import '../../../../routes/route_names.dart';
import '../../../../core/widgets/app_snackbar.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = ref.read(authRepositoryProvider);
    final user = authRepository.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle(title: "Account"),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.edit_rounded,
                title: "Edit Profile",
                subtitle: "Update your profile information",
                onTap: () {
                  context.push(RouteNames.editProfile);
                },
              ),
              _SettingsTile(
                icon: Icons.lock_reset_rounded,
                title: "Change Password",
                subtitle: "Receive a password reset email",
                onTap: () async {
                  final email = user?.email;
                  if (email == null) return;

                  await authRepository.sendPasswordResetEmail(email: email);

                  if (!context.mounted) return;

                  AppSnackbar.success(
                    context,
                    "Password reset email sent.",
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.mark_email_read_rounded,
                title: "Resend Verification Email",
                subtitle: "Send a new verification email",
                onTap: () async {
                  await authRepository.resendVerificationEmail();

                  if (!context.mounted) return;

                  AppSnackbar.success(
                    context,
                    "Verification email sent.",
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text("Email"),
                subtitle: Text(user?.email ?? "Unknown"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SectionTitle(title: "Privacy"),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.block_rounded,
                title: "Blocked Users",
                subtitle: "Manage blocked contacts",
                onTap: () {
                  context.push(RouteNames.blockedUsers);
                },
              ),
              SwitchListTile(
                value: true,
                onChanged: null,
                secondary: const Icon(Icons.circle_rounded),
                title: const Text("Online Status"),
                subtitle: const Text("Coming soon"),
              ),
              SwitchListTile(
                value: true,
                onChanged: null,
                secondary: const Icon(Icons.done_all_rounded),
                title: const Text("Read Receipts"),
                subtitle: const Text("Coming soon"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SectionTitle(title: "Appearance"),

          _SettingsCard(
            children: const [
              ListTile(
                leading: Icon(Icons.palette_rounded),
                title: Text("Theme"),
                subtitle: Text("Coming soon"),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode_rounded),
                title: Text("Dark Mode"),
                subtitle: Text("Coming soon"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SectionTitle(title: "About"),

          _SettingsCard(
            children: const [
              ListTile(
                leading: Icon(Icons.favorite_rounded),
                title: Text("PurpleChat"),
                subtitle: Text("Version 1.0.0"),
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text("About PurpleChat"),
                subtitle: Text(
                  "A simple, modern real-time chat application built with Flutter & Firebase.",
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _SectionTitle(title: "Danger Zone"),

          Card(
            elevation: 0,
            color: Colors.red.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  iconColor: Colors.red,
                  title: "Logout",
                  subtitle: "Sign out from PurpleChat",
                  titleColor: Colors.red,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text(
                          "Are you sure you want to logout?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    await ref.read(authControllerProvider).logout();

                    if (!context.mounted) return;

                    context.go(RouteNames.login);
                  },
                ),
                _SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: Colors.red,
                  title: "Delete Account",
                  subtitle: "Coming soon",
                  titleColor: Colors.red,
                  onTap: () {
                    AppSnackbar.info(
                      context,
                      "Delete account will be available in a future update.",
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
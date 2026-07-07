import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verify Email'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 90),
              const SizedBox(height: 24),

              const Text(
                'Please verify your email before continuing.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              AppButton(
                text: 'I Have Verified',
                onPressed: () async {
                  final verified = await ref
                      .read(authControllerProvider)
                      .isEmailVerified();

                  if (!mounted) return;

                  if (verified) {
                    context.go(RouteNames.home);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Email not verified yet.')),
                    );
                  }
                },
              ),

              const SizedBox(height: 16),

              AppButton(
                text: 'Resend Email',
                onPressed: () async {
                  await ref
                      .read(authControllerProvider)
                      .resendVerificationEmail();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent.')),
                  );
                },
              ),

              const SizedBox(height: 16),

              AppButton(
                text: 'Logout',
                onPressed: () async {
                  await ref.read(authControllerProvider).logout();

                  if (!mounted) return;

                  context.go(RouteNames.login);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

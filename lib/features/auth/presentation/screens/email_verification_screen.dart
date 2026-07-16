import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../../../../core/widgets/app_snackbar.dart';

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
              Icon(
                Icons.mark_email_read_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 20),

              Text(
                "Verify Your Email",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "We've sent a verification link to your email address.\n"
                "Click the link, then return here and tap the button below.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 36),

              AppButton(
                text: 'Continue',
                onPressed: () async {
                  final verified = await ref
                      .read(authControllerProvider)
                      .isEmailVerified();

                  if (!mounted) return;

                  if (verified) {
                    context.go(RouteNames.home);
                  } else {
                    AppSnackbar.error(context, 'Email not verified yet.');
                  }
                },
              ),

              const SizedBox(height: 16),

              AppButton(
                text: 'Resend Verification Email',
                onPressed: () async {
                  await ref
                      .read(authControllerProvider)
                      .resendVerificationEmail();

                  if (!mounted) return;

                  AppSnackbar.success(context, 'Verification email sent.');
                },
              ),


              const SizedBox(height: 20),

              TextButton(
                onPressed: () async {
                  await ref.read(authControllerProvider).logout();

                  if (!mounted) return;

                  context.go(RouteNames.login);
                },
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

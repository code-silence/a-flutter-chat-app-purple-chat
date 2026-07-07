import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);

    final result = await ref
        .read(authControllerProvider)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    setState(() => _loading = false);

    if (!result.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    final verified = await ref.read(authControllerProvider).isEmailVerified();

    if (!mounted) return;

    if (verified) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.emailVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(controller: _emailController, label: 'Email'),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: _loading ? 'Logging in...' : 'Login',
                onPressed: _loading ? null : _login,
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  context.push(RouteNames.forgotPassword);
                },
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  context.push(RouteNames.register);
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';
import '../../../../core/widgets/app_snackbar.dart';

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
    if (_emailController.text.trim().isEmpty) {
      AppSnackbar.error(context, 'Please enter your email address.');
      return;
    }

    if (_passwordController.text.isEmpty) {
      AppSnackbar.error(context, 'Did you forget to enter your password?');
      return;
    }

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
      AppSnackbar.error(context, result.message);
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

          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                const Icon(
                  Icons.chat_bubble_rounded,
                  size: 72,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 20),

                Text(
                  "Welcome Back",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Sign in to continue chatting.",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),

                const SizedBox(height: 36),
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
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    context.push(RouteNames.forgotPassword);
                  },
                  child: const Text('Forgot Password?'),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        context.push(RouteNames.register);
                      },
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

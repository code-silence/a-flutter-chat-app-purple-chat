import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routes/route_names.dart';
import '../../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));
      return;
    }

    setState(() => _loading = true);

    final result = await ref
        .read(authControllerProvider)
        .register(
          username: _usernameController.text,
          displayName: _displayNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    setState(() => _loading = false);

    if (result.success) {
      if (!mounted) return;

      context.go(RouteNames.emailVerification);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AppTextField(controller: _usernameController, label: 'Username'),
              const SizedBox(height: 16),

              AppTextField(
                controller: _displayNameController,
                label: 'Display Name',
              ),
              const SizedBox(height: 16),

              AppTextField(controller: _emailController, label: 'Email'),
              const SizedBox(height: 16),

              AppTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                obscureText: true,
              ),
              const SizedBox(height: 24),

              AppButton(
                text: _loading ? 'Creating...' : 'Create Account',
                onPressed: _loading ? null : _register,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

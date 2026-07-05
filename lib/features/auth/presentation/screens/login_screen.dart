import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_names.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              context.go(RouteNames.register);
            },
            child: const Text('Go to Register'),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/auth/providers/auth_providers.dart';
import '../../../../routes/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      setState(() {
        _animate = true;
      });
    });

    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final controller = ref.read(authControllerProvider);

    final loggedIn = controller.isLoggedIn();

    if (!mounted) return;

    if (!loggedIn) {
      context.go(RouteNames.login);
      return;
    }

    final verified = await controller.shouldGoToHome();

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
      backgroundColor: const Color.fromARGB(255, 182, 123, 233),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  scale: _animate ? 1 : 0.85,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 600),
                    opacity: _animate ? 1 : 0,
                    child: Image.asset(
                      "assets/icon/pc_app_icon.png",
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 900),
                  opacity: _animate ? 1 : 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "PurpleChat",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 1300),
                        opacity: _animate ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 6,
                            bottom: 4,
                          ),
                          child: Text(
                            "BETA",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 1800),
                  opacity: _animate ? 1 : 0,
                  child: Text(
                    "Stay connected with your friends.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 15,
                    ),
                  ),
                ),

                const SizedBox(height: 42),

                AnimatedOpacity(
                  duration: const Duration(milliseconds: 1400),
                  opacity: _animate ? 1 : 0,
                  child: const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
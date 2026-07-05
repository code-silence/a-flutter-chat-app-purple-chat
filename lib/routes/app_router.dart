import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';
import '../features/auth/presentation/screens/register_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  routes: [

    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),

  ],
);
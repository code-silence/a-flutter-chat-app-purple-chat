import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/email_verification_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/friends/presentation/screens/friend_requests_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/friends/presentation/screens/friend_profile_screen.dart';
import '../features/auth/models/user_model.dart';

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

    GoRoute(
      path: RouteNames.emailVerification,
      builder: (context, state) => const EmailVerificationScreen(),
    ),

    GoRoute(
      path: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: RouteNames.home,
      builder: (context, state) => const HomeScreen(),
    ),

    GoRoute(
      path: RouteNames.search,
      builder: (context, state) => const SearchScreen(),
    ),

    GoRoute(
      path: RouteNames.friendRequests,
      builder: (context, state) => const FriendRequestsScreen(),
    ),

    GoRoute(
      path: RouteNames.profile,
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: RouteNames.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),

    GoRoute(
      path: RouteNames.settings,
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: RouteNames.friendProfile,
      builder: (context, state) {
        final friend = state.extra as UserModel;

        return FriendProfileScreen(friend: friend);
      },
    ),
  ],
);

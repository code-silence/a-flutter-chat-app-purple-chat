import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/route_names.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../friends/presentation/screens/friends_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PurpleChat'),
        actions: [
          IconButton(
            onPressed: () {
              context.push(RouteNames.search);
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              context.push(RouteNames.friendRequests);
            },
            icon: const Icon(Icons.group_add),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider).logout();

              if (!context.mounted) return;

              context.go(RouteNames.login);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const SafeArea(child: FriendsScreen()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

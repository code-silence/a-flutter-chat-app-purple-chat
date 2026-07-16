import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/route_names.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../chat/presentation/screens/chats_screen.dart';
import '../../../friends/presentation/screens/friends_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "PurpleChat",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Stay connected!",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Search",
            onPressed: () => context.push(RouteNames.search),
            icon: const Icon(Icons.manage_search_rounded),
          ),

          IconButton(
            tooltip: "Requests",
            onPressed: () => context.push(RouteNames.friendRequests),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),

          IconButton(
            tooltip: "Friends",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FriendsScreen()),
              );
            },
            icon: const Icon(Icons.groups_rounded),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == "profile") {
                context.push(RouteNames.profile);
              } else if (value == "logout") {
                await ref.read(authControllerProvider).logout();

                if (!context.mounted) return;

                context.go(RouteNames.login);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "profile",
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text("Profile"),
                ),
              ),
              PopupMenuItem(
                value: "logout",
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ),
            ],
          ),
        ],
      ),
      body: const SafeArea(child: ChatsScreen()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RouteNames.search);
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text("Add Friend"),
      ),
    );
  }
}

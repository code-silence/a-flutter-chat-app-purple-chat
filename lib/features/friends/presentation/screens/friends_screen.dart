import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../../providers/friend_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(friendRepositoryProvider);

    return StreamBuilder<List<String>>(
      stream: repository.getFriends(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data!;

        if (friends.isEmpty) {
          return const Center(child: Text('No friends yet'));
        }

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final uid = friends[index];

            return FutureBuilder<UserModel?>(
              future: repository.getUser(uid),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(title: Text('Loading...'));
                }

                final user = userSnapshot.data!;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.displayName[0].toUpperCase()),
                  ),
                  title: Text(user.displayName),
                  subtitle: Text('@${user.username}'),
                  trailing: Icon(
                    user.isOnline ? Icons.circle : Icons.access_time,
                    size: 14,
                    color: user.isOnline ? Colors.green : Colors.grey,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(friend: user),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

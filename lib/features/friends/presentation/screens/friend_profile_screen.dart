import 'package:flutter/material.dart';
import '../../../auth/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/friend_provider.dart';

class FriendProfileScreen extends ConsumerWidget {
  final UserModel friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),

              CircleAvatar(
                radius: 50,
                backgroundImage: friend.photoUrl.isNotEmpty
                    ? NetworkImage(friend.photoUrl)
                    : null,
                child: friend.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),

              const SizedBox(height: 16),

              Text(
                friend.displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text('@${friend.username}'),

              const SizedBox(height: 12),

              Text(friend.bio),

              const SizedBox(height: 30),

              FilledButton(onPressed: () {}, child: const Text('Message')),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Remove Friend'),
                        content: Text(
                          'Remove ${friend.displayName} from your friends?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Remove'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  await ref
                      .read(friendRepositoryProvider)
                      .removeFriend(friend.uid);

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                child: const Text('Remove Friend'),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Block User'),
                      content: Text(
                        'Block ${friend.displayName}? They will no longer be able to message or send friend requests.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Block'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  await ref
                      .read(friendRepositoryProvider)
                      .blockUser(friend.uid);

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                child: const Text('Block User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

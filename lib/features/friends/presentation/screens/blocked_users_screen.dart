import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/friend_provider.dart';
import '../../../auth/models/user_model.dart';

class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(friendRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: StreamBuilder<List<String>>(
        stream: repo.blockedUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final blocked = snapshot.data!;

          if (blocked.isEmpty) {
            return const Center(child: Text('No blocked users'));
          }

          return ListView.builder(
            itemCount: blocked.length,
            itemBuilder: (context, index) {
              return FutureBuilder<UserModel?>(
                future: repo.getUser(blocked[index]),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const SizedBox();
                  }

                  final user = userSnap.data!;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user.photoUrl.isNotEmpty
                          ? NetworkImage(user.photoUrl)
                          : null,
                      child: user.photoUrl.isEmpty
                          ? Text(user.displayName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(user.displayName),
                    subtitle: Text('@${user.username}'),
                    trailing: TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Unblock User'),
                            content: Text('Unblock ${user.displayName}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Unblock'),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        await repo.unblockUser(user.uid);
                      },
                      child: const Text('Unblock'),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/friend_request.dart';
import '../../providers/friend_provider.dart';

class FriendRequestsScreen extends ConsumerWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(friendRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: StreamBuilder<List<FriendRequest>>(
        stream: repository.getRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;

          if (requests.isEmpty) {
            return const Center(child: Text('No friend requests'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return ListTile(
                title: FutureBuilder(
                  future: repository.getUser(request.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('Loading...');
                    }

                    final user = snapshot.data!;

                    return Text(user.displayName);
                  },
                ),
                subtitle: FutureBuilder(
                  future: repository.getUser(request.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final user = snapshot.data!;

                    return Text('@${user.username}');
                  },
                ),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        repository.rejectRequest(request.uid);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        repository.acceptRequest(request.uid);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

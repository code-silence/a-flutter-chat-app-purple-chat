import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/friend_request.dart';
import '../../providers/friend_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';

class FriendRequestsScreen extends ConsumerStatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  ConsumerState<FriendRequestsScreen> createState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends ConsumerState<FriendRequestsScreen> {
  final Set<String> _acceptedRequests = {};
  final Set<String> _rejectedRequests = {};
  @override
  Widget build(BuildContext context) {
    final repository = ref.read(friendRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Friend Requests')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Friend Requests",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              "Accept or decline people who want to connect with you.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<FriendRequest>>(
                stream: repository.getRequests(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final requests = snapshot.data!;

                  if (requests.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No Friend Requests",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "When someone sends you a request,\nit will appear here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];

                      return FutureBuilder(
                        future: repository.getUser(request.uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const ListTile(title: Text('Loading...'));
                          }

                          final user = snapshot.data!;

                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  backgroundImage: user.photoUrl.isNotEmpty
                                      ? NetworkImage(user.photoUrl)
                                      : null,
                                  child: user.photoUrl.isEmpty
                                      ? Text(user.displayName[0].toUpperCase())
                                      : null,
                                ),

                                title: Text(user.displayName),

                                subtitle: Text('@${user.username}'),

                                trailing:
                                    _acceptedRequests.contains(request.uid)
                                    ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Friends",
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : _rejectedRequests.contains(request.uid)
                                    ? const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.cancel_rounded,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Declined",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.close_rounded,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              AppSnackbar.error(
                                                context,
                                                "Request Rejected.",
                                              );
                                              await repository.rejectRequest(
                                                request.uid,
                                              );

                                              if (!mounted) return;

                                              setState(() {
                                                _rejectedRequests.add(
                                                  request.uid,
                                                );
                                              });

                                              
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.check_circle_rounded,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                            onPressed: () async {
                                              AppSnackbar.success(
                                                context,
                                                "You are now friends!",
                                              );
                                              await repository.acceptRequest(
                                                request.uid,
                                              );

                                              if (!mounted) return;

                                              setState(() {
                                                _acceptedRequests.add(
                                                  request.uid,
                                                );
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

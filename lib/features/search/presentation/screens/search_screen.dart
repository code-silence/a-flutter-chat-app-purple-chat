import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../../providers/search_provider.dart';
import '../../../../../features/friends/providers/friend_provider.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';


class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final controller = TextEditingController();

  UserModel? user;

  bool loading = false;

  Future<void> search() async {
    setState(() => loading = true);

    user = await ref.read(searchControllerProvider).findUser(controller.text);

    debugPrint('Result: $user');

    setState(() => loading = false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find Friends")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Search by Username",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Find friends and send them a friend request.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              AppTextField(
                onSubmitted: (_) => search(),
                textInputAction: TextInputAction.search,
                controller: controller,
                label: 'Username',
              ),

              const SizedBox(height: 24),

              if (loading) const CircularProgressIndicator(),

              if (!loading && user != null)
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage: user!.photoUrl.isNotEmpty
                              ? NetworkImage(user!.photoUrl)
                              : null,
                          child: user!.photoUrl.isEmpty
                              ? Text(user!.displayName[0].toUpperCase())
                              : null,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user!.displayName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '@${user!.username}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        FutureBuilder<String>(
                          future: ref
                              .read(friendRepositoryProvider)
                              .relationshipStatus(user!.uid),
                          builder: (context, statusSnap) {
                            if (!statusSnap.hasData) {
                              return const SizedBox(
                                width: 80,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final status = statusSnap.data!;

                            if (status == 'friends') {
                              return const SizedBox(
                                width: 110,
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Text('Friends'),
                                ),
                              );
                            }

                            if (status == 'request_sent') {
                              return const SizedBox(
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Text('Sent'),
                                ),
                              );
                            }

                            if (status == 'request_received') {
                              return SizedBox(
                                width: 120,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await ref
                                        .read(friendRepositoryProvider)
                                        .acceptRequest(user!.uid);

                                    if (!mounted) return;

                                    setState(() {});
                                  },
                                  child: const Text('Accept'),
                                ),
                              );
                            }

                            if (status == 'blocked') {
                              return const SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Text('Blocked'),
                                ),
                              );
                            }

                            return SizedBox(
                              width: 80,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref
                                      .read(friendRepositoryProvider)
                                      .sendRequest(user!.uid);

                                  if (!mounted) return;

                                  setState(() {});

                                  AppSnackbar.success(
                                    context,
                                    'Friend request sent.',
                                  );
                                },
                                child: const Text('Add'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../../providers/search_provider.dart';
import '../../../../../features/friends/providers/friend_provider.dart';

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
      appBar: AppBar(title: const Text('Search User')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Username',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: search,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (loading) const CircularProgressIndicator(),

              if (!loading && user != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
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
                              Text(user!.displayName),
                              Text('@${user!.username}'),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: 80,
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(friendRepositoryProvider)
                                  .sendRequest(user!.uid);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Friend request sent.'),
                                ),
                              );
                            },
                            child: const Text('Add'),
                          ),
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

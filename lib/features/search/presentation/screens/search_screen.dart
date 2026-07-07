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
                ListTile(
                  title: Text(user!.displayName),
                  subtitle: Text('@${user!.username}'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(friendRepositoryProvider)
                          .sendRequest(user!.uid);

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Friend request sent.')),
                      );
                    },
                    child: const Text('Add'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

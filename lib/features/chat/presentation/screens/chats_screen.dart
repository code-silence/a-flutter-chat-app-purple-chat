import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/time_utils.dart';
import '../../../auth/models/user_model.dart';
import '../../models/chat_model.dart';
import '../../providers/chat_provider.dart';
import 'chat_screen.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(chatRepositoryProvider);

    return StreamBuilder<List<ChatModel>>(
      stream: repo.chatStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data!;

        if (chats.isEmpty) {
          return const Center(child: Text('No chats yet'));
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];

            return FutureBuilder<UserModel?>(
              future: repo.getFriend(chat),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const SizedBox();
                }

                final friend = userSnap.data!;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(friend.displayName[0].toUpperCase()),
                  ),
                  trailing: StreamBuilder<int>(
                    stream: repo.unreadCount(friend.uid),
                    builder: (context, unreadSnap) {
                      final unread = unreadSnap.data ?? 0;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(TimeUtils.formatChatTime(chat.lastMessageTime)),

                          if (unread > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unread',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  title: Text(friend.displayName),
                  subtitle: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(friend: friend),
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

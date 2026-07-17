import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/message_status.dart';
import '../../../../../core/utils/time_utils.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/route_names.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final UserModel friend;

  const ChatScreen({super.key, required this.friend});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRepositoryProvider).markMessagesAsRead(widget.friend.uid);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    _controller.clear();

    await ref
        .read(chatRepositoryProvider)
        .sendMessage(friendUid: widget.friend.uid, text: text);
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.read(chatRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: StreamBuilder<UserModel>(
          stream: repository.userStream(widget.friend.uid),
          builder: (context, snapshot) {
            final user = snapshot.data ?? widget.friend;

            return InkWell(
              onTap: () {
                context.push(RouteNames.friendProfile, extra: user);
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? Text(user.displayName[0].toUpperCase())
                        : null,
                  ),

                  const SizedBox(width: 12),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 9,
                            color: user.isOnline ? Colors.green : Colors.grey,
                          ),

                          const SizedBox(width: 5),

                          Text(
                            user.isOnline ? "Online" : "Offline",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: repository.messageStream(widget.friend.uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  ref
                      .read(chatRepositoryProvider)
                      .markMessagesAsRead(widget.friend.uid);

                  final messages = snapshot.data!;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            "Start chatting with ${widget.friend.displayName}",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Say hello 👋",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      return Align(
                        alignment: message.senderUid == widget.friend.uid
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 6,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: message.senderUid == widget.friend.uid
                                ? Colors.grey.shade300
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(
                                message.senderUid == widget.friend.uid ? 4 : 18,
                              ),
                              bottomRight: Radius.circular(
                                message.senderUid == widget.friend.uid ? 18 : 4,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  color: message.senderUid == widget.friend.uid
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),

                              if (message.senderUid ==
                                  FirebaseAuth.instance.currentUser?.uid)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: MessageStatus.icon(message),
                                ),

                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  TimeUtils.formatMessageTime(message.sentAt),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        message.senderUid == widget.friend.uid
                                        ? Colors.black54
                                        : Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          prefixIcon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    FloatingActionButton.small(
                      heroTag: "sendButton",
                      elevation: 0,
                      onPressed: _send,
                      child: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

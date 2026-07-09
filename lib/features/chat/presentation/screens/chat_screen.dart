import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/models/user_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/message_status.dart';
import '../../../../../core/utils/time_utils.dart';

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
      appBar: AppBar(title: Text(widget.friend.displayName)),
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
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: message.senderUid == widget.friend.uid
                                ? Colors.grey.shade300
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.senderUid == widget.friend.uid
                                      ? Colors.black
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Message'),
                      ),
                    ),
                    IconButton(onPressed: _send, icon: const Icon(Icons.send)),
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

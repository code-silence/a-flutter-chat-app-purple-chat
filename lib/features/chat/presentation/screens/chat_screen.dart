import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/models/user_model.dart';
import '../../models/message_model.dart';
import '../../providers/chat_provider.dart';
import '../../../../core/utils/message_status.dart';
import '../../../../../core/utils/time_utils.dart';
import '../../../../core/providers/imgbb_provider.dart';
import '../../../../routes/route_names.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/image_viewer_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final UserModel friend;

  const ChatScreen({super.key, required this.friend});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _sendingImage = false;

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

  // =========================
  // SEND TEXT
  // =========================

  Future<void> _send() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    _controller.clear();

    await ref
        .read(chatRepositoryProvider)
        .sendMessage(friendUid: widget.friend.uid, text: text);
  }

  // =========================
  // SEND IMAGE
  // =========================

  Future<void> _pickAndSendImage() async {
    if (_sendingImage) return;

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (picked == null) return;

    final originalFile = File(picked.path);

    // Maximum allowed image size: 25 MB
    final originalSize = await originalFile.length();

    if (originalSize > 25 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image must be smaller than 25 MB.')),
      );

      return;
    }

    setState(() {
      _sendingImage = true;
    });

    try {
      final compressedPath = '${originalFile.path}_chat_compressed.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        originalFile.path,
        compressedPath,
        quality: 80,
        format: CompressFormat.jpeg,
      );

      if (compressed == null) {
        throw Exception('Failed to compress image.');
      }

      final compressedFile = File(compressed.path);

      final compressedSize = await compressedFile.length();

      if (compressedSize > 25 * 1024 * 1024) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image is still larger than 25 MB.')),
        );

        return;
      }

      final result = await ref
          .read(imgbbServiceProvider)
          .upload(compressedFile);

      final imageUrl = result['photoUrl'] as String?;

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Image upload failed.');
      }

      await ref
          .read(chatRepositoryProvider)
          .sendImageMessage(friendUid: widget.friend.uid, imageUrl: imageUrl);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send image. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sendingImage = false;
        });
      }
    }
  }

  // =========================
  // SCROLL
  // =========================

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
            // =========================
            // MESSAGES
            // =========================
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

                  _scrollToBottom();

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];

                      final isMe =
                          message.senderUid ==
                          FirebaseAuth.instance.currentUser?.uid;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 6,
                          ),
                          padding: message.isImage
                              ? const EdgeInsets.all(5)
                              : const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isMe ? 18 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (message.isImage)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ImageViewerScreen(
                                          imageUrl: message.imageUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: CachedNetworkImage(
                                      imageUrl: message.imageUrl,
                                      width: 240,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) {
                                        return const SizedBox(
                                          width: 240,
                                          height: 180,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                      errorWidget: (context, url, error) {
                                        return const SizedBox(
                                          width: 240,
                                          height: 180,
                                          child: Center(
                                            child: Icon(
                                              Icons.broken_image_rounded,
                                              size: 40,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                              if (!message.isImage)
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    color: isMe ? Colors.white : Colors.black87,
                                  ),
                                ),

                              Padding(
                                padding: EdgeInsets.only(
                                  top: message.isImage ? 3 : 2,
                                  right: message.isImage ? 4 : 0,
                                  left: message.isImage ? 4 : 0,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      TimeUtils.formatMessageTime(
                                        message.sentAt,
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),

                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      MessageStatus.icon(message),
                                    ],
                                  ],
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

            // =========================
            // INPUT
            // =========================
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
                    IconButton(
                      tooltip: 'Send image',
                      onPressed: _sendingImage ? null : _pickAndSendImage,
                      icon: _sendingImage
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image_rounded),
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                          contentPadding: EdgeInsets.symmetric(
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

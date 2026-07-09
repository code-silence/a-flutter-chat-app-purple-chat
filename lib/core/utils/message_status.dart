import 'package:flutter/material.dart';

import '../../features/chat/models/message_model.dart';

class MessageStatus {
  MessageStatus._();

  static Widget icon(MessageModel message) {
    if (message.readAt > 0) {
      return const Icon(Icons.done_all, size: 16, color: Colors.blue);
    }

    if (message.deliveredAt > 0) {
      return const Icon(Icons.done_all, size: 16);
    }

    return const Icon(Icons.done, size: 16);
  }
}
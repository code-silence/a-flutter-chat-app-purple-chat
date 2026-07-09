class ChatModel {
  final String chatId;
  final String lastMessage;
  final int lastMessageTime;
  final String lastSenderUid;
  final Map<dynamic, dynamic> members;

  const ChatModel({
    required this.chatId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderUid,
    required this.members,
  });

  factory ChatModel.fromMap(
    String chatId,
    Map<dynamic, dynamic> map,
  ) {
    return ChatModel(
      chatId: chatId,
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] ?? 0,
      lastSenderUid: map['lastSenderUid'] ?? '',
      members: Map<dynamic, dynamic>.from(
        map['members'] ?? {},
      ),
    );
  }
}
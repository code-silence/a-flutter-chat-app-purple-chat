class MessageModel {
  final String id;
  final String senderUid;
  final String text;
  final String type;
  final String imageUrl;
  final int sentAt;
  final int deliveredAt;
  final int readAt;

  const MessageModel({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.type,
    required this.imageUrl,
    required this.sentAt,
    required this.deliveredAt,
    required this.readAt,
  });

  bool get isImage => type == 'image';

  factory MessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return MessageModel(
      id: id,
      senderUid: map['senderUid'] ?? '',
      text: map['text'] ?? '',
      type: map['type'] ?? 'text',
      imageUrl: map['imageUrl'] ?? '',
      sentAt: map['sentAt'] ?? 0,
      deliveredAt: map['deliveredAt'] ?? 0,
      readAt: map['readAt'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderUid': senderUid,
      'text': text,
      'type': type,
      'imageUrl': imageUrl,
      'sentAt': sentAt,
      'deliveredAt': deliveredAt,
      'readAt': readAt,
    };
  }
}
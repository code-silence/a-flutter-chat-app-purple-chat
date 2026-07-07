class FriendRequest {
  final String uid;
  final int sentAt;
  final String status;

  const FriendRequest({
    required this.uid,
    required this.sentAt,
    required this.status,
  });

  factory FriendRequest.fromMap(
    String uid,
    Map<dynamic, dynamic> map,
  ) {
    return FriendRequest(
      uid: uid,
      sentAt: map['sentAt'] ?? 0,
      status: map['status'] ?? 'pending',
    );
  }
}
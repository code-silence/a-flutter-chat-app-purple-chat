class UserModel {
  final String uid;
  final String username;
  final String displayName;
  final String email;
  final String photoUrl;
  final String photoDeleteUrl;
  final String bio;
  final bool isOnline;
  final int lastSeen;
  final int createdAt;

  const UserModel({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.photoDeleteUrl,
    required this.bio,
    required this.isOnline,
    required this.lastSeen,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? username,
    String? displayName,
    String? email,
    String? photoUrl,
    String? photoDeleteUrl,
    String? bio,
    bool? isOnline,
    int? lastSeen,
    int? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      photoDeleteUrl: photoDeleteUrl ?? this.photoDeleteUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'photoDeleteUrl': photoDeleteUrl,
      'bio': bio,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      photoDeleteUrl: map['photoDeleteUrl'] ?? '',
      bio: map['bio'] ?? '',
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] ?? 0,
      createdAt: map['createdAt'] ?? 0,
    );
  }
}

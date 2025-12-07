class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final int recipesCount;
  final int likesCount;
  final int savedCount;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.recipesCount = 0,
    this.likesCount = 0,
    this.savedCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      recipesCount: map['recipesCount'] ?? 0,
      likesCount: map['likesCount'] ?? 0,
      savedCount: map['savedCount'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'recipesCount': recipesCount,
      'likesCount': likesCount,
      'savedCount': savedCount,
      'createdAt': createdAt,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    int? recipesCount,
    int? likesCount,
    int? savedCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      recipesCount: recipesCount ?? this.recipesCount,
      likesCount: likesCount ?? this.likesCount,
      savedCount: savedCount ?? this.savedCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


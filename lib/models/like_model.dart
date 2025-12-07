class LikeModel {
  final String id;
  final String userId;
  final String recipeId;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.createdAt,
  });

  factory LikeModel.fromMap(Map<String, dynamic> map, String id) {
    return LikeModel(
      id: id,
      userId: map['userId'] ?? '',
      recipeId: map['recipeId'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'recipeId': recipeId,
      'createdAt': createdAt,
    };
  }
}


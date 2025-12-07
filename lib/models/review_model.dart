class ReviewModel {
  final String id;
  final String recipeId;
  final String userId;
  final String? userName;
  final String? userPhotoUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      recipeId: map['recipeId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'],
      userPhotoUrl: map['userPhotoUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? recipeId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


class RecipeModel {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  final String authorId;
  final String? authorName;
  final int likesCount;
  final int savesCount;
  final double rating;
  final int reviewsCount;
  final DateTime createdAt;

  RecipeModel({
    required this.id,
    required this.title,
    this.description,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.authorId,
    this.authorName,
    this.likesCount = 0,
    this.savesCount = 0,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.createdAt,
  });

  factory RecipeModel.fromMap(Map<String, dynamic> map, String id) {
    return RecipeModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      category: map['category'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'],
      likesCount: map['likesCount'] ?? 0,
      savesCount: map['savesCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'authorId': authorId,
      'authorName': authorName,
      'likesCount': likesCount,
      'savesCount': savesCount,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'createdAt': createdAt,
    };
  }

  RecipeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? ingredients,
    List<String>? steps,
    String? category,
    String? authorId,
    String? authorName,
    int? likesCount,
    int? savesCount,
    double? rating,
    int? reviewsCount,
    DateTime? createdAt,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


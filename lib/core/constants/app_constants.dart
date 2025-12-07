class AppConstants {
  // App Info
  static const String appName = 'Dish Flow';
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusPill = 999.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Recipe Categories
  static const List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Snacks',
    'Vegetarian',
    'Vegan',
    'Gluten-Free',
    'Quick & Easy',
  ];
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String recipesCollection = 'recipes';
  static const String reviewsCollection = 'reviews';
  static const String likesCollection = 'likes';
  static const String savesCollection = 'saves';
}


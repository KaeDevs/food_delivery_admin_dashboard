class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String category;
  final double price;
  final String dietaryTag; // 'veg' | 'non-veg' | 'vegan' | 'egg'
  final bool hasDietaryTagError;
  final bool isInStock;
  final DateTime lastUpdated;
  final bool hasPhoto;
  final bool isPhotoApproved;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.category,
    required this.price,
    required this.dietaryTag,
    this.hasDietaryTagError = false,
    this.isInStock = true,
    required this.lastUpdated,
    this.hasPhoto = true,
    this.isPhotoApproved = true,
  });

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? category,
    double? price,
    String? dietaryTag,
    bool? hasDietaryTagError,
    bool? isInStock,
    DateTime? lastUpdated,
    bool? hasPhoto,
    bool? isPhotoApproved,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      dietaryTag: dietaryTag ?? this.dietaryTag,
      hasDietaryTagError: hasDietaryTagError ?? this.hasDietaryTagError,
      isInStock: isInStock ?? this.isInStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hasPhoto: hasPhoto ?? this.hasPhoto,
      isPhotoApproved: isPhotoApproved ?? this.isPhotoApproved,
    );
  }
}

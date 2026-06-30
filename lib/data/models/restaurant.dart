enum RestaurantStatus {
  active,
  inactive,
  suspended,
  pendingOnboarding,
  underReview,
}

enum DocumentStatus {
  pending,
  underReview,
  approved,
  rejected,
  expired,
}

class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final String zoneId;
  final RestaurantStatus status;
  final double rating;
  final double rejectionRate;
  final int avgPrepTimeMinutes;
  final int promisedPrepTimeMinutes;
  final DocumentStatus fssaiStatus;
  final DocumentStatus gstStatus;
  final DateTime? fssaiExpiry;
  final double weeklySettlementPending;
  final int totalOrdersThisMonth;
  final bool isOnline;
  final List<String> imageUrls;

  /// Mock GPS coordinates for map display.
  final double latitude;
  final double longitude;

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.zoneId,
    required this.status,
    required this.rating,
    required this.rejectionRate,
    required this.avgPrepTimeMinutes,
    required this.promisedPrepTimeMinutes,
    required this.fssaiStatus,
    required this.gstStatus,
    this.fssaiExpiry,
    required this.weeklySettlementPending,
    required this.totalOrdersThisMonth,
    required this.isOnline,
    this.imageUrls = const [],
    this.latitude = 12.9716,
    this.longitude = 77.5946,
  });

  Restaurant copyWith({
    String? id,
    String? name,
    String? cuisine,
    String? zoneId,
    RestaurantStatus? status,
    double? rating,
    double? rejectionRate,
    int? avgPrepTimeMinutes,
    int? promisedPrepTimeMinutes,
    DocumentStatus? fssaiStatus,
    DocumentStatus? gstStatus,
    DateTime? fssaiExpiry,
    double? weeklySettlementPending,
    int? totalOrdersThisMonth,
    bool? isOnline,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      zoneId: zoneId ?? this.zoneId,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      rejectionRate: rejectionRate ?? this.rejectionRate,
      avgPrepTimeMinutes: avgPrepTimeMinutes ?? this.avgPrepTimeMinutes,
      promisedPrepTimeMinutes:
          promisedPrepTimeMinutes ?? this.promisedPrepTimeMinutes,
      fssaiStatus: fssaiStatus ?? this.fssaiStatus,
      gstStatus: gstStatus ?? this.gstStatus,
      fssaiExpiry: fssaiExpiry ?? this.fssaiExpiry,
      weeklySettlementPending:
          weeklySettlementPending ?? this.weeklySettlementPending,
      totalOrdersThisMonth:
          totalOrdersThisMonth ?? this.totalOrdersThisMonth,
      isOnline: isOnline ?? this.isOnline,
      imageUrls: imageUrls ?? this.imageUrls,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String get statusLabel {
    switch (status) {
      case RestaurantStatus.active:
        return 'Active';
      case RestaurantStatus.inactive:
        return 'Inactive';
      case RestaurantStatus.suspended:
        return 'Suspended';
      case RestaurantStatus.pendingOnboarding:
        return 'Pending Onboarding';
      case RestaurantStatus.underReview:
        return 'Under Review';
    }
  }
}

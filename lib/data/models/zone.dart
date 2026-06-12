class Zone {
  final String id;
  final String name;
  final double centerLat;
  final double centerLng;
  final int activeOrders;
  final int availableRiders;
  final double demandSupplyRatio;
  final bool isSurgeActive;

  const Zone({
    required this.id,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.activeOrders,
    required this.availableRiders,
    required this.demandSupplyRatio,
    this.isSurgeActive = false,
  });

  Zone copyWith({
    String? id,
    String? name,
    double? centerLat,
    double? centerLng,
    int? activeOrders,
    int? availableRiders,
    double? demandSupplyRatio,
    bool? isSurgeActive,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
      activeOrders: activeOrders ?? this.activeOrders,
      availableRiders: availableRiders ?? this.availableRiders,
      demandSupplyRatio: demandSupplyRatio ?? this.demandSupplyRatio,
      isSurgeActive: isSurgeActive ?? this.isSurgeActive,
    );
  }
}

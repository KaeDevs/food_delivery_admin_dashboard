class KpiSnapshot {
  final DateTime date;
  final int orderVolume;
  final double gmv;
  final double aov;
  final int activeRestaurants;
  final int activeRiders;
  final double onTimeRate;
  final double cancellationRate;
  final double refundRate;

  const KpiSnapshot({
    required this.date,
    required this.orderVolume,
    required this.gmv,
    required this.aov,
    required this.activeRestaurants,
    required this.activeRiders,
    required this.onTimeRate,
    required this.cancellationRate,
    required this.refundRate,
  });

  KpiSnapshot copyWith({
    DateTime? date,
    int? orderVolume,
    double? gmv,
    double? aov,
    int? activeRestaurants,
    int? activeRiders,
    double? onTimeRate,
    double? cancellationRate,
    double? refundRate,
  }) {
    return KpiSnapshot(
      date: date ?? this.date,
      orderVolume: orderVolume ?? this.orderVolume,
      gmv: gmv ?? this.gmv,
      aov: aov ?? this.aov,
      activeRestaurants: activeRestaurants ?? this.activeRestaurants,
      activeRiders: activeRiders ?? this.activeRiders,
      onTimeRate: onTimeRate ?? this.onTimeRate,
      cancellationRate: cancellationRate ?? this.cancellationRate,
      refundRate: refundRate ?? this.refundRate,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalOrders;
  final double lifetimeValue;
  final double refundRate;
  final bool isPromoAbuser;
  final double churnRiskScore;
  final String subscriptionStatus; // 'none' | 'active' | 'expired'
  final DateTime lastOrderDate;
  final String acquisitionCohort; // 'YYYY-MM'
  final String locationArea;
  final String fullAddress;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.totalOrders,
    required this.lifetimeValue,
    required this.refundRate,
    required this.isPromoAbuser,
    required this.churnRiskScore,
    required this.subscriptionStatus,
    required this.lastOrderDate,
    required this.acquisitionCohort,
    required this.locationArea,
    required this.fullAddress,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    int? totalOrders,
    double? lifetimeValue,
    double? refundRate,
    bool? isPromoAbuser,
    double? churnRiskScore,
    String? subscriptionStatus,
    DateTime? lastOrderDate,
    String? acquisitionCohort,
    String? locationArea,
    String? fullAddress,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      totalOrders: totalOrders ?? this.totalOrders,
      lifetimeValue: lifetimeValue ?? this.lifetimeValue,
      refundRate: refundRate ?? this.refundRate,
      isPromoAbuser: isPromoAbuser ?? this.isPromoAbuser,
      churnRiskScore: churnRiskScore ?? this.churnRiskScore,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      acquisitionCohort: acquisitionCohort ?? this.acquisitionCohort,
      locationArea: locationArea ?? this.locationArea,
      fullAddress: fullAddress ?? this.fullAddress,
    );
  }
}

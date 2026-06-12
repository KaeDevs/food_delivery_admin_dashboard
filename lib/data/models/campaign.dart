enum CampaignType { percentOff, flatOff, freeDelivery, bogo, freeItem }

enum CampaignStatus { active, paused, ended, scheduled }

class Campaign {
  final String id;
  final String name;
  final CampaignType type;
  final CampaignStatus status;
  final double discountValue;
  final int redemptionCount;
  final int maxRedemptions;
  final double totalSubsidy;
  final double incrementalOrders;
  final DateTime startDate;
  final DateTime endDate;

  const Campaign({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.discountValue,
    required this.redemptionCount,
    required this.maxRedemptions,
    required this.totalSubsidy,
    required this.incrementalOrders,
    required this.startDate,
    required this.endDate,
  });

  Campaign copyWith({
    String? id,
    String? name,
    CampaignType? type,
    CampaignStatus? status,
    double? discountValue,
    int? redemptionCount,
    int? maxRedemptions,
    double? totalSubsidy,
    double? incrementalOrders,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Campaign(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      discountValue: discountValue ?? this.discountValue,
      redemptionCount: redemptionCount ?? this.redemptionCount,
      maxRedemptions: maxRedemptions ?? this.maxRedemptions,
      totalSubsidy: totalSubsidy ?? this.totalSubsidy,
      incrementalOrders: incrementalOrders ?? this.incrementalOrders,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  String get typeLabel {
    switch (type) {
      case CampaignType.percentOff:
        return 'Percent Off';
      case CampaignType.flatOff:
        return 'Flat Off';
      case CampaignType.freeDelivery:
        return 'Free Delivery';
      case CampaignType.bogo:
        return 'BOGO';
      case CampaignType.freeItem:
        return 'Free Item';
    }
  }

  String get statusLabel {
    switch (status) {
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.ended:
        return 'Ended';
      case CampaignStatus.scheduled:
        return 'Scheduled';
    }
  }
}

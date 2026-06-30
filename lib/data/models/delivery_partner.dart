enum RiderStatus { available, assigned, delivering, offline, suspended }

enum DisciplineOutcome {
  cleared,
  formalWarning,
  shortSuspension,
  longSuspension,
  permanentBan,
}

class DisciplineEvent {
  final String id;
  final DateTime date;
  final String offenceType;
  final DisciplineOutcome outcome;
  final String adminNote;

  const DisciplineEvent({
    required this.id,
    required this.date,
    required this.offenceType,
    required this.outcome,
    required this.adminNote,
  });

  DisciplineEvent copyWith({
    String? id,
    DateTime? date,
    String? offenceType,
    DisciplineOutcome? outcome,
    String? adminNote,
  }) {
    return DisciplineEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      offenceType: offenceType ?? this.offenceType,
      outcome: outcome ?? this.outcome,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}

class DeliveryPartner {
  final String id;
  final String name;
  final String phone;
  final String zoneId;
  final RiderStatus status;
  final double rating;
  final double acceptanceRate;
  final double completionRate;
  final double onTimeDeliveryRate;
  final double earningsThisWeek;
  final double earningsToday;
  final int deliveriesThisMonth;
  final int warningCount;
  final bool isSuspended;
  final String licenceStatus;
  final DateTime? licenceExpiry;
  final List<DisciplineEvent> disciplineHistory;

  /// Mock GPS coordinates for map display.
  final double latitude;
  final double longitude;

  const DeliveryPartner({
    required this.id,
    required this.name,
    required this.phone,
    required this.zoneId,
    required this.status,
    required this.rating,
    required this.acceptanceRate,
    required this.completionRate,
    required this.onTimeDeliveryRate,
    required this.earningsThisWeek,
    required this.earningsToday,
    required this.deliveriesThisMonth,
    required this.warningCount,
    required this.isSuspended,
    required this.licenceStatus,
    this.licenceExpiry,
    this.disciplineHistory = const [],
    this.latitude = 12.9716,
    this.longitude = 77.5946,
  });

  DeliveryPartner copyWith({
    String? id,
    String? name,
    String? phone,
    String? zoneId,
    RiderStatus? status,
    double? rating,
    double? acceptanceRate,
    double? completionRate,
    double? onTimeDeliveryRate,
    double? earningsThisWeek,
    double? earningsToday,
    int? deliveriesThisMonth,
    int? warningCount,
    bool? isSuspended,
    String? licenceStatus,
    DateTime? licenceExpiry,
    List<DisciplineEvent>? disciplineHistory,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryPartner(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      zoneId: zoneId ?? this.zoneId,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      completionRate: completionRate ?? this.completionRate,
      onTimeDeliveryRate: onTimeDeliveryRate ?? this.onTimeDeliveryRate,
      earningsThisWeek: earningsThisWeek ?? this.earningsThisWeek,
      earningsToday: earningsToday ?? this.earningsToday,
      deliveriesThisMonth: deliveriesThisMonth ?? this.deliveriesThisMonth,
      warningCount: warningCount ?? this.warningCount,
      isSuspended: isSuspended ?? this.isSuspended,
      licenceStatus: licenceStatus ?? this.licenceStatus,
      licenceExpiry: licenceExpiry ?? this.licenceExpiry,
      disciplineHistory: disciplineHistory ?? this.disciplineHistory,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  String get statusLabel {
    switch (status) {
      case RiderStatus.available:
        return 'Available';
      case RiderStatus.assigned:
        return 'Assigned';
      case RiderStatus.delivering:
        return 'Delivering';
      case RiderStatus.offline:
        return 'Offline';
      case RiderStatus.suspended:
        return 'Suspended';
    }
  }
}

enum AlertSeverity { info, warning, critical }

class AlertRule {
  final String id;
  final String name;
  final AlertSeverity severity;
  final String triggerCondition;
  final double thresholdValue;
  final bool isActive;
  final String ownerRole;
  final bool isFired;
  final DateTime? firedAt;

  const AlertRule({
    required this.id,
    required this.name,
    required this.severity,
    required this.triggerCondition,
    required this.thresholdValue,
    required this.isActive,
    required this.ownerRole,
    this.isFired = false,
    this.firedAt,
  });

  AlertRule copyWith({
    String? id,
    String? name,
    AlertSeverity? severity,
    String? triggerCondition,
    double? thresholdValue,
    bool? isActive,
    String? ownerRole,
    bool? isFired,
    DateTime? firedAt,
  }) {
    return AlertRule(
      id: id ?? this.id,
      name: name ?? this.name,
      severity: severity ?? this.severity,
      triggerCondition: triggerCondition ?? this.triggerCondition,
      thresholdValue: thresholdValue ?? this.thresholdValue,
      isActive: isActive ?? this.isActive,
      ownerRole: ownerRole ?? this.ownerRole,
      isFired: isFired ?? this.isFired,
      firedAt: firedAt ?? this.firedAt,
    );
  }

  String get severityLabel {
    switch (severity) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }
}

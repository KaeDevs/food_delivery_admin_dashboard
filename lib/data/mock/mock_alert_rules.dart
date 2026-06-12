import '../models/alert_rule.dart';

class MockAlertRules {
  static List<AlertRule> rules = [];

  static void seed() {
    final now = DateTime.now();
    rules = [
      AlertRule(id: 'alert-001', name: 'Rider shortage in Koramangala', severity: AlertSeverity.critical, triggerCondition: 'D/S ratio > 1.5 in zone', thresholdValue: 1.5, isActive: true, ownerRole: 'Dispatch Admin', isFired: true, firedAt: now.subtract(const Duration(minutes: 15))),
      AlertRule(id: 'alert-002', name: 'Restaurant below rating threshold: Spice Garden', severity: AlertSeverity.warning, triggerCondition: 'Restaurant rating < 3.5', thresholdValue: 3.5, isActive: true, ownerRole: 'Merchant Success Admin', isFired: true, firedAt: now.subtract(const Duration(hours: 2))),
      AlertRule(id: 'alert-003', name: 'Payment gateway failure spike: UPI', severity: AlertSeverity.critical, triggerCondition: 'UPI failure rate > 5% in 1 hour', thresholdValue: 0.05, isActive: true, ownerRole: 'Finance Admin', isFired: true, firedAt: now.subtract(const Duration(minutes: 45))),
      AlertRule(id: 'alert-004', name: 'SLA breach rate exceeds threshold: Whitefield', severity: AlertSeverity.critical, triggerCondition: 'SLA breach rate > 15% in zone', thresholdValue: 0.15, isActive: true, ownerRole: 'Operations Admin', isFired: true, firedAt: now.subtract(const Duration(hours: 1))),
      AlertRule(id: 'alert-005', name: 'Promo abuse pattern detected', severity: AlertSeverity.warning, triggerCondition: 'Customer promo dependency > 60%', thresholdValue: 0.6, isActive: true, ownerRole: 'Trust & Safety Admin', isFired: true, firedAt: now.subtract(const Duration(hours: 3))),
      AlertRule(id: 'alert-006', name: 'High cancellation rate', severity: AlertSeverity.warning, triggerCondition: 'Cancellation rate > 8% daily', thresholdValue: 0.08, isActive: true, ownerRole: 'Operations Admin', isFired: false),
      AlertRule(id: 'alert-007', name: 'Restaurant FSSAI expiring', severity: AlertSeverity.info, triggerCondition: 'FSSAI expiry within 30 days', thresholdValue: 30, isActive: true, ownerRole: 'Merchant Success Admin', isFired: false),
      AlertRule(id: 'alert-008', name: 'Rider licence expiring', severity: AlertSeverity.info, triggerCondition: 'Licence expiry within 30 days', thresholdValue: 30, isActive: true, ownerRole: 'Operations Admin', isFired: false),
      AlertRule(id: 'alert-009', name: 'Settlement overdue', severity: AlertSeverity.warning, triggerCondition: 'Settlement pending > 7 days', thresholdValue: 7, isActive: true, ownerRole: 'Finance Admin', isFired: false),
      AlertRule(id: 'alert-010', name: 'Zone demand surge', severity: AlertSeverity.info, triggerCondition: 'Order volume > 150% of hourly average', thresholdValue: 1.5, isActive: true, ownerRole: 'Dispatch Admin', isFired: false),
    ];
  }
}

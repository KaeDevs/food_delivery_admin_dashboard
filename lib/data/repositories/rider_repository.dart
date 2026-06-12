import '../models/delivery_partner.dart';
import '../mock/mock_riders.dart';

class RiderRepository {
  static List<DeliveryPartner> getAll() => MockRiders.riders;
  static DeliveryPartner? getById(String id) {
    try { return MockRiders.riders.firstWhere((r) => r.id == id); } catch (_) { return null; }
  }
  static List<DeliveryPartner> getByZone(String zoneId) => MockRiders.riders.where((r) => r.zoneId == zoneId).toList();
  static List<DeliveryPartner> getByStatus(RiderStatus status) => MockRiders.riders.where((r) => r.status == status).toList();
  static List<DeliveryPartner> getAvailable() => MockRiders.riders.where((r) => r.status == RiderStatus.available).toList();
  static List<DeliveryPartner> getWithWarnings() => MockRiders.riders.where((r) => r.warningCount >= 2).toList();
  static List<DeliveryPartner> getSuspended() => MockRiders.riders.where((r) => r.isSuspended).toList();
}

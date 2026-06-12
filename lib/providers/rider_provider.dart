import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/delivery_partner.dart';
import '../data/mock/mock_riders.dart';

final riderProvider = StateNotifierProvider<RiderListNotifier, List<DeliveryPartner>>((ref) {
  return RiderListNotifier();
});

class RiderListNotifier extends StateNotifier<List<DeliveryPartner>> {
  RiderListNotifier() : super(MockRiders.riders);

  void updateRider(String id, DeliveryPartner updated) {
    state = state.map((r) => r.id == id ? updated : r).toList();
  }
}

final ridersWithWarningsProvider = Provider<List<DeliveryPartner>>((ref) {
  return ref.watch(riderProvider).where((r) => r.warningCount >= 2).toList();
});

final availableRidersProvider = Provider<List<DeliveryPartner>>((ref) {
  return ref.watch(riderProvider).where((r) => r.status == RiderStatus.available).toList();
});

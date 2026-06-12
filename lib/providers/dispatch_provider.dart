import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/zone.dart';
import '../data/mock/mock_seed.dart';

final dispatchProvider = StateNotifierProvider<DispatchNotifier, DispatchState>((ref) => DispatchNotifier());

class DispatchState {
  final List<Zone> zones;
  final double proximityWeight;
  final double fairnessWeight;
  final double slaWeight;
  final bool batchEligibility;
  final int maxConcurrentPerRider;

  const DispatchState({
    this.zones = const [],
    this.proximityWeight = 0.4,
    this.fairnessWeight = 0.3,
    this.slaWeight = 0.3,
    this.batchEligibility = true,
    this.maxConcurrentPerRider = 2,
  });

  DispatchState copyWith({
    List<Zone>? zones,
    double? proximityWeight,
    double? fairnessWeight,
    double? slaWeight,
    bool? batchEligibility,
    int? maxConcurrentPerRider,
  }) {
    return DispatchState(
      zones: zones ?? this.zones,
      proximityWeight: proximityWeight ?? this.proximityWeight,
      fairnessWeight: fairnessWeight ?? this.fairnessWeight,
      slaWeight: slaWeight ?? this.slaWeight,
      batchEligibility: batchEligibility ?? this.batchEligibility,
      maxConcurrentPerRider: maxConcurrentPerRider ?? this.maxConcurrentPerRider,
    );
  }
}

class DispatchNotifier extends StateNotifier<DispatchState> {
  DispatchNotifier() : super(DispatchState(zones: MockZones.zones));

  void toggleSurge(String zoneId) {
    final zones = state.zones.map((z) {
      if (z.id == zoneId) return z.copyWith(isSurgeActive: !z.isSurgeActive);
      return z;
    }).toList();
    state = state.copyWith(zones: zones);
  }

  void updateRules({double? proximity, double? fairness, double? sla, bool? batch, int? maxConcurrent}) {
    state = state.copyWith(
      proximityWeight: proximity,
      fairnessWeight: fairness,
      slaWeight: sla,
      batchEligibility: batch,
      maxConcurrentPerRider: maxConcurrent,
    );
  }
}

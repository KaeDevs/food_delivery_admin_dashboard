import 'package:flutter_riverpod/flutter_riverpod.dart';

final geoProvider = StateNotifierProvider<GeoNotifier, GeoState>((ref) => GeoNotifier());

class GeoState {
  final Map<String, bool> layerVisibility;

  const GeoState({
    this.layerVisibility = const {
      'riders': true,
      'restaurants': true,
      'orders': true,
      'zones': true,
      'demandHeat': false,
      'supplyHeat': false,
    },
  });

  GeoState copyWith({Map<String, bool>? layerVisibility}) {
    return GeoState(layerVisibility: layerVisibility ?? this.layerVisibility);
  }
}

class GeoNotifier extends StateNotifier<GeoState> {
  GeoNotifier() : super(const GeoState());

  void toggleLayer(String layer) {
    final updated = Map<String, bool>.from(state.layerVisibility);
    updated[layer] = !(updated[layer] ?? false);
    state = state.copyWith(layerVisibility: updated);
  }
}

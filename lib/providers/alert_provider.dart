import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/alert_rule.dart';
import '../data/mock/mock_alert_rules.dart';

final alertProvider = StateNotifierProvider<AlertNotifier, List<AlertRule>>((ref) => AlertNotifier());

class AlertNotifier extends StateNotifier<List<AlertRule>> {
  AlertNotifier() : super(MockAlertRules.rules);

  void dismiss(String id) {
    state = state.map((a) => a.id == id ? a.copyWith(isFired: false) : a).toList();
  }

  void dismissAll() {
    state = state.map((a) => a.copyWith(isFired: false)).toList();
  }

  void toggle(String id) {
    state = state.map((a) => a.id == id ? a.copyWith(isActive: !a.isActive) : a).toList();
  }
}

final firedAlertsProvider = Provider<List<AlertRule>>((ref) => ref.watch(alertProvider).where((a) => a.isFired).toList());
final firedAlertCountProvider = Provider<int>((ref) => ref.watch(firedAlertsProvider).length);

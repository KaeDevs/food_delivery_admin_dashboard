import 'dart:math';
import '../models/kpi_snapshot.dart';

class MockKpiSnapshots {
  static List<KpiSnapshot> snapshots = [];

  static void seed() {
    final now = DateTime.now();
    final rng = Random(42);

    snapshots = List.generate(30, (i) {
      final day = now.subtract(Duration(days: 29 - i));
      // GMV trending upward with some dips
      double baseGmv = 120000 + (i * 2500) + (rng.nextDouble() * 15000 - 5000);
      // Spike incident on day 15 (cancellation rate)
      double cancellationRate = 0.04 + rng.nextDouble() * 0.03;
      if (i == 15) {
        cancellationRate = 0.15; // incident spike
        baseGmv *= 0.85; // dip during incident
      }
      // On-time rate drop on days 20-22
      double onTimeRate = 0.88 + rng.nextDouble() * 0.08;
      if (i >= 20 && i <= 22) {
        onTimeRate = 0.72 + rng.nextDouble() * 0.05;
      }

      final orderVolume = (baseGmv / (350 + rng.nextInt(150))).round();

      return KpiSnapshot(
        date: day,
        orderVolume: orderVolume,
        gmv: baseGmv,
        aov: baseGmv / orderVolume,
        activeRestaurants: 14 + rng.nextInt(5),
        activeRiders: 18 + rng.nextInt(6),
        onTimeRate: onTimeRate,
        cancellationRate: cancellationRate,
        refundRate: 0.02 + rng.nextDouble() * 0.03,
      );
    });
  }
}

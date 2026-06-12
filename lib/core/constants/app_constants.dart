class AppConstants {
  AppConstants._();

  // SLA thresholds
  static const double restaurantRatingThreshold = 3.5;
  static const int slaBreachMinutes = 10;
  static const double riderWarningThreshold = 2;
  static const double fairnessDeviationThreshold = 0.3;
  static const double demandSupplyShortageRatio = 1.5;
  static const double demandSupplyOversupplyRatio = 0.5;
  static const double churnRiskThreshold = 0.7;
  static const double refundAbuseThreshold = 0.3;
  static const double promoAbuseThreshold = 0.6;
  static const int settlementCycleDays = 7;

  // Mock city center (Bengaluru)
  static const double cityLat = 12.9716;
  static const double cityLng = 77.5946;

  // Zone IDs
  static const List<String> zoneIds = [
    'koramangala',
    'whitefield',
    'indiranagar',
    'hsr_layout',
    'electronic_city',
    'jayanagar',
  ];

  // Zone display names
  static const Map<String, String> zoneNames = {
    'koramangala': 'Koramangala',
    'whitefield': 'Whitefield',
    'indiranagar': 'Indiranagar',
    'hsr_layout': 'HSR Layout',
    'electronic_city': 'Electronic City',
    'jayanagar': 'Jayanagar',
  };

  // Admin roles
  static const List<String> adminRoles = [
    'Super Admin',
    'Operations Admin',
    'Dispatch Admin',
    'Finance Admin',
    'Trust & Safety Admin',
    'Merchant Success Admin',
    'Support Admin',
    'Analyst',
  ];

  // Dispatch rule defaults
  static const double defaultProximityWeight = 0.4;
  static const double defaultFairnessWeight = 0.3;
  static const double defaultSlaWeight = 0.3;
  static const bool defaultBatchEligibility = true;
  static const int defaultMaxConcurrentPerRider = 2;
}

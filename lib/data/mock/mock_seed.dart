import '../models/admin_user.dart';
import '../models/zone.dart';

class MockAdminUsers {
  static List<AdminUser> users = [];

  static void seed() {
    final now = DateTime.now();
    users = [
      AdminUser(
        id: 'admin-001',
        name: 'Thiruu',
        email: 'thiru@admin.com',
        role: 'Super Admin',
        scope: 'global',
        isActive: true,
        lastLogin: now.subtract(const Duration(minutes: 30)),
      ),
      AdminUser(
        id: 'admin-002',
        name: 'Priya Sharma',
        email: 'priya@admin.com',
        role: 'Operations Admin',
        scope: 'global',
        isActive: true,
        lastLogin: now.subtract(const Duration(hours: 2)),
      ),
      AdminUser(
        id: 'admin-003',
        name: 'Arjun Reddy',
        email: 'arjun@admin.com',
        role: 'Dispatch Admin',
        scope: 'Bengaluru',
        isActive: true,
        lastLogin: now.subtract(const Duration(hours: 1)),
      ),
      AdminUser(
        id: 'admin-004',
        name: 'Sneha Patel',
        email: 'sneha@admin.com',
        role: 'Finance Admin',
        scope: 'global',
        isActive: true,
        lastLogin: now.subtract(const Duration(hours: 4)),
      ),
      AdminUser(
        id: 'admin-005',
        name: 'Vikram Singh',
        email: 'vikram@admin.com',
        role: 'Trust & Safety Admin',
        scope: 'global',
        isActive: true,
        lastLogin: now.subtract(const Duration(hours: 3)),
      ),
      AdminUser(
        id: 'admin-006',
        name: 'Anjali Menon',
        email: 'anjali@admin.com',
        role: 'Merchant Success Admin',
        scope: 'Bengaluru',
        isActive: true,
        lastLogin: now.subtract(const Duration(hours: 6)),
      ),
      AdminUser(
        id: 'admin-007',
        name: 'Rahul Gupta',
        email: 'rahul@admin.com',
        role: 'Support Admin',
        scope: 'global',
        isActive: true,
        lastLogin: now.subtract(const Duration(hours: 1)),
      ),
      AdminUser(
        id: 'admin-008',
        name: 'Meera Iyer',
        email: 'meera@admin.com',
        role: 'Analyst',
        scope: 'global',
        isActive: true,
        lastLogin: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}

class MockZones {
  static List<Zone> zones = [];

  // ---------------------------------------------------------------------------
  // Hexagonal boundary polygons (~1.5 km radius) for each Bengaluru zone.
  // Points are ordered clockwise starting from the northernmost vertex.
  // ---------------------------------------------------------------------------

  static void seed() {
    zones = [
      const Zone(
        id: 'koramangala',
        name: 'Koramangala',
        centerLat: 12.9352,
        centerLng: 77.6245,
        activeOrders: 12,
        availableRiders: 5,
        demandSupplyRatio: 2.4,
        isSurgeActive: true,
        coordinates: [
          GeoPoint(12.9487, 77.6245),
          GeoPoint(12.9420, 77.6379),
          GeoPoint(12.9284, 77.6379),
          GeoPoint(12.9217, 77.6245),
          GeoPoint(12.9284, 77.6111),
          GeoPoint(12.9420, 77.6111),
        ],
      ),
      const Zone(
        id: 'whitefield',
        name: 'Whitefield',
        centerLat: 12.9698,
        centerLng: 77.7500,
        activeOrders: 8,
        availableRiders: 6,
        demandSupplyRatio: 1.3,
        isSurgeActive: false,
        coordinates: [
          GeoPoint(12.9833, 77.7500),
          GeoPoint(12.9766, 77.7634),
          GeoPoint(12.9630, 77.7634),
          GeoPoint(12.9563, 77.7500),
          GeoPoint(12.9630, 77.7366),
          GeoPoint(12.9766, 77.7366),
        ],
      ),
      const Zone(
        id: 'indiranagar',
        name: 'Indiranagar',
        centerLat: 12.9784,
        centerLng: 77.6408,
        activeOrders: 10,
        availableRiders: 7,
        demandSupplyRatio: 1.4,
        isSurgeActive: false,
        coordinates: [
          GeoPoint(12.9919, 77.6408),
          GeoPoint(12.9852, 77.6542),
          GeoPoint(12.9716, 77.6542),
          GeoPoint(12.9649, 77.6408),
          GeoPoint(12.9716, 77.6274),
          GeoPoint(12.9852, 77.6274),
        ],
      ),
      const Zone(
        id: 'hsr_layout',
        name: 'HSR Layout',
        centerLat: 12.9116,
        centerLng: 77.6389,
        activeOrders: 6,
        availableRiders: 8,
        demandSupplyRatio: 0.75,
        isSurgeActive: false,
        coordinates: [
          GeoPoint(12.9251, 77.6389),
          GeoPoint(12.9184, 77.6523),
          GeoPoint(12.9048, 77.6523),
          GeoPoint(12.8981, 77.6389),
          GeoPoint(12.9048, 77.6255),
          GeoPoint(12.9184, 77.6255),
        ],
      ),
      const Zone(
        id: 'electronic_city',
        name: 'Electronic City',
        centerLat: 12.8399,
        centerLng: 77.6770,
        activeOrders: 4,
        availableRiders: 3,
        demandSupplyRatio: 1.3,
        isSurgeActive: false,
        coordinates: [
          GeoPoint(12.8534, 77.6770),
          GeoPoint(12.8467, 77.6904),
          GeoPoint(12.8331, 77.6904),
          GeoPoint(12.8264, 77.6770),
          GeoPoint(12.8331, 77.6636),
          GeoPoint(12.8467, 77.6636),
        ],
      ),
      const Zone(
        id: 'jayanagar',
        name: 'Jayanagar',
        centerLat: 12.9308,
        centerLng: 77.5826,
        activeOrders: 3,
        availableRiders: 7,
        demandSupplyRatio: 0.4,
        isSurgeActive: false,
        coordinates: [
          GeoPoint(12.9443, 77.5826),
          GeoPoint(12.9376, 77.5960),
          GeoPoint(12.9240, 77.5960),
          GeoPoint(12.9173, 77.5826),
          GeoPoint(12.9240, 77.5692),
          GeoPoint(12.9376, 77.5692),
        ],
      ),
    ];
  }
}

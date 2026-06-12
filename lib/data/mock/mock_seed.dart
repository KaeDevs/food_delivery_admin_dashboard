import '../models/admin_user.dart';
import '../models/zone.dart';

class MockAdminUsers {
  static List<AdminUser> users = [];

  static void seed() {
    final now = DateTime.now();
    users = [
      AdminUser(
        id: 'admin-001',
        name: 'Rajesh Kumar',
        email: 'rajesh@admin.com',
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
      ),
    ];
  }
}

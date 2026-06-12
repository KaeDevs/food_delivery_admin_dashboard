import '../models/campaign.dart';

class MockCampaigns {
  static List<Campaign> campaigns = [];

  static void seed() {
    final now = DateTime.now();
    campaigns = [
      Campaign(id: 'camp-001', name: 'New User Welcome', type: CampaignType.percentOff, status: CampaignStatus.active, discountValue: 50, redemptionCount: 1250, maxRedemptions: 5000, totalSubsidy: 312500, incrementalOrders: 875, startDate: now.subtract(const Duration(days: 15)), endDate: now.add(const Duration(days: 15))),
      Campaign(id: 'camp-002', name: 'Weekend Feast', type: CampaignType.flatOff, status: CampaignStatus.active, discountValue: 100, redemptionCount: 800, maxRedemptions: 2000, totalSubsidy: 80000, incrementalOrders: 520, startDate: now.subtract(const Duration(days: 5)), endDate: now.add(const Duration(days: 2))),
      Campaign(id: 'camp-003', name: 'Free Delivery Week', type: CampaignType.freeDelivery, status: CampaignStatus.active, discountValue: 40, redemptionCount: 2100, maxRedemptions: 10000, totalSubsidy: 84000, incrementalOrders: 1450, startDate: now.subtract(const Duration(days: 3)), endDate: now.add(const Duration(days: 4))),
      Campaign(id: 'camp-004', name: 'Buy 1 Get 1 Biryani', type: CampaignType.bogo, status: CampaignStatus.paused, discountValue: 200, redemptionCount: 450, maxRedemptions: 1000, totalSubsidy: 90000, incrementalOrders: 310, startDate: now.subtract(const Duration(days: 10)), endDate: now.add(const Duration(days: 5))),
      Campaign(id: 'camp-005', name: 'Dessert Delight', type: CampaignType.freeItem, status: CampaignStatus.ended, discountValue: 80, redemptionCount: 600, maxRedemptions: 600, totalSubsidy: 48000, incrementalOrders: 380, startDate: now.subtract(const Duration(days: 20)), endDate: now.subtract(const Duration(days: 5))),
      Campaign(id: 'camp-006', name: 'Lunch Express', type: CampaignType.percentOff, status: CampaignStatus.active, discountValue: 30, redemptionCount: 1800, maxRedemptions: 3000, totalSubsidy: 162000, incrementalOrders: 1100, startDate: now.subtract(const Duration(days: 7)), endDate: now.add(const Duration(days: 7))),
      Campaign(id: 'camp-007', name: 'Midnight Munchies', type: CampaignType.flatOff, status: CampaignStatus.scheduled, discountValue: 75, redemptionCount: 0, maxRedemptions: 1500, totalSubsidy: 0, incrementalOrders: 0, startDate: now.add(const Duration(days: 2)), endDate: now.add(const Duration(days: 9))),
      Campaign(id: 'camp-008', name: 'Healthy Choices', type: CampaignType.percentOff, status: CampaignStatus.ended, discountValue: 25, redemptionCount: 350, maxRedemptions: 500, totalSubsidy: 43750, incrementalOrders: 220, startDate: now.subtract(const Duration(days: 30)), endDate: now.subtract(const Duration(days: 10))),
    ];
  }
}

import '../models/campaign.dart';
import '../mock/mock_campaigns.dart';

class CampaignRepository {
  static List<Campaign> getAll() => MockCampaigns.campaigns;
  static List<Campaign> getActive() => MockCampaigns.campaigns.where((c) => c.status == CampaignStatus.active).toList();
  static Campaign? getById(String id) {
    try { return MockCampaigns.campaigns.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }
}

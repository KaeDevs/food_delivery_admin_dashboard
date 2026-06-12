import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/campaign.dart';
import '../data/mock/mock_campaigns.dart';

final campaignProvider = StateNotifierProvider<CampaignNotifier, List<Campaign>>((ref) => CampaignNotifier());

class CampaignNotifier extends StateNotifier<List<Campaign>> {
  CampaignNotifier() : super(MockCampaigns.campaigns);
  void updateCampaign(String id, Campaign updated) { state = state.map((c) => c.id == id ? updated : c).toList(); }
}

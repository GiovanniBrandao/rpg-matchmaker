// lib/features/table_search/model/campaign_search_model.dart
import '../../profile/model/master_model.dart';

class CampaignSearchModel {
  final MasterModel campaign;
  final String masterId;
  final String masterName;

  const CampaignSearchModel({
    required this.campaign,
    required this.masterId,
    required this.masterName,
  });

  factory CampaignSearchModel.fromFirestore({
    required Map<String, dynamic> campaignMap,
    required String masterId,
    required String masterName,
  }) {
    return CampaignSearchModel(
      campaign: MasterModel.fromMap(campaignMap),
      masterId: masterId,
      masterName: masterName,
    );
  }
}
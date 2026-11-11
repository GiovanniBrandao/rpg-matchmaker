import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/campaign_search_model.dart';
import '../model/character_search_model.dart';
import '../../profile/model/character_model.dart'; // Import do CharacterModel
import '../../profile/model/user_profile_model.dart';

class TableSearchService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Busca todas as campanhas criadas por mestres
  Future<List<CampaignSearchModel>> fetchAllCampaigns() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'master')
          .get();

      List<CampaignSearchModel> campaigns = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final masterName = data['name'] ?? 'Mestre Desconhecido';
        final rawCampaigns = data['campaigns'] as List? ?? [];

        for (var c in rawCampaigns) {
          if (c is Map<String, dynamic>) {
            campaigns.add(
              CampaignSearchModel.fromFirestore(
                campaignMap: c,
                masterId: doc.id,
                masterName: masterName,
              ),
            );
          }
        }
      }

      return campaigns;
    } catch (e) {
      throw Exception('Erro ao buscar campanhas: $e');
    }
  }

  /// Busca todos os personagens cadastrados por jogadores no banco
  Future<List<CharacterSearchModel>> fetchAllCharacters() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'player')
          .get();

      List<CharacterSearchModel> charactersList = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final playerName = data['name'] ?? 'Jogador Desconhecido';
        final proficiency = ProficiencyLevel.fromString(data['proficiency']);
        final rawCharacters = data['characters'] as List? ?? [];

        for (var c in rawCharacters) {
          if (c is Map<String, dynamic>) {
            charactersList.add(
              CharacterSearchModel(
                character: CharacterModel.fromMap(c), // CORRIGIDO: de CharacterSearchModel para CharacterModel
                playerId: doc.id,
                playerName: playerName,
                proficiency: proficiency,
              ),
            );
          }
        }
      }

      return charactersList;
    } catch (e) {
      throw Exception('Erro ao buscar personagens: $e');
    }
  }
}
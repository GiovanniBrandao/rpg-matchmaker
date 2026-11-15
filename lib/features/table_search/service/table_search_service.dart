// lib/features/table_search/service/table_search_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/campaign_search_model.dart';
import '../model/character_search_model.dart';
import '../../profile/model/character_model.dart';
import '../../profile/model/master_model.dart';
import '../../profile/model/user_profile_model.dart';

class TableSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Busca todas as campanhas diretamente da coleção raiz 'campaigns'
  Future<List<CampaignSearchModel>> fetchAllCampaigns() async {
    try {
      final snapshot = await _firestore.collection('campaigns').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final campaign = MasterModel.fromMap(data, docId: doc.id);

        return CampaignSearchModel(
          campaign: campaign,
          masterId: campaign.masterId,
          masterName: campaign.masterName.isNotEmpty 
              ? campaign.masterName 
              : 'Mestre Desconhecido',
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar campanhas: $e');
    }
  }

  /// Busca todos os personagens diretamente da coleção raiz 'characters'
  Future<List<CharacterSearchModel>> fetchAllCharacters() async {
    try {
      // 1. Busca os personagens na coleção raiz
      final snapshot = await _firestore.collection('characters').get();

      // 2. Busca os dados dos usuários para vincular a proficiência
      final usersSnapshot = await _firestore.collection('users').get();
      final usersMap = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final character = CharacterModel.fromMap(data, docId: doc.id);
        final userData = usersMap[character.playerId];

        final proficiency = ProficiencyLevel.fromString(userData?['proficiency']);

        return CharacterSearchModel(
          character: character,
          playerId: character.playerId,
          playerName: character.playerName.isNotEmpty 
              ? character.playerName 
              : (userData?['name'] ?? 'Jogador Desconhecido'),
          proficiency: proficiency,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao buscar personagens: $e');
    }
  }
}
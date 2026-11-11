// lib/features/table_search/model/character_search_model.dart
import '../../profile/model/character_model.dart';
import '../../profile/model/user_profile_model.dart';

class CharacterSearchModel {
  final CharacterModel character;
  final String playerId;
  final String playerName;
  final ProficiencyLevel proficiency;

  const CharacterSearchModel({
    required this.character,
    required this.playerId,
    required this.playerName,
    required this.proficiency,
  });
}
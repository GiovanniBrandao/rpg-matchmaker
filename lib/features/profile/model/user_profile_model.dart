import 'character_model.dart';
import 'master_model.dart';

enum ProficiencyLevel {
  iniciante('Iniciante'),
  intermed('Intermediário'),
  avancado('Avançado');

  final String label;
  const ProficiencyLevel(this.label);

  static ProficiencyLevel fromString(String? val) {
    switch (val) {
      case 'iniciante':
        return ProficiencyLevel.iniciante;
      case 'avancado':
        return ProficiencyLevel.avancado;
      default:
        return ProficiencyLevel.intermed;
    }
  }
}

class UserProfileModel {
  final String id;
  final String userName;
  final String email;
  final bool isGameMaster;
  final ProficiencyLevel proficiency;
  final List<String> favoriteSystems;
  final List<MasterModel> campaigns;
  final List<CharacterModel> characters;

  const UserProfileModel({
    required this.id,
    required this.userName,
    required this.email,
    this.isGameMaster = false,
    required this.proficiency,
    required this.favoriteSystems,
    this.campaigns = const [],
    this.characters = const [],
  });

  factory UserProfileModel.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<MasterModel>? campaigns,
    List<CharacterModel>? characters,
  }) {
    return UserProfileModel(
      id: id,
      userName: (map['name'] as String?)?.isNotEmpty == true
          ? map['name']
          : (map['userName'] ?? ''),
      email: map['email'] ?? '',
      isGameMaster: map['role'] == 'master',
      proficiency: ProficiencyLevel.fromString(map['proficiency'] as String?),
      favoriteSystems: List<String>.from(map['systems'] ?? []),
      campaigns: campaigns ?? [],
      characters: characters ?? [],
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? userName,
    String? email,
    bool? isGameMaster,
    ProficiencyLevel? proficiency,
    List<String>? favoriteSystems,
    List<MasterModel>? campaigns,
    List<CharacterModel>? characters,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      isGameMaster: isGameMaster ?? this.isGameMaster,
      proficiency: proficiency ?? this.proficiency,
      favoriteSystems: favoriteSystems ?? this.favoriteSystems,
      campaigns: campaigns ?? this.campaigns,
      characters: characters ?? this.characters,
    );
  }
}
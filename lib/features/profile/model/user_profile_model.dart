import 'character_model.dart';
import 'master_model.dart';

enum ProficiencyLevel {
  inexperient('Inexperiente'),
  beginner('Iniciante'),
  intermed('Intermediário'),
  experienced('Experiente');

  final String label;
  const ProficiencyLevel(this.label);

  static ProficiencyLevel fromString(String? value) {
    return ProficiencyLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProficiencyLevel.intermed,
    );
  }
}

class UserProfileModel {
  final String id;
  final String userName;
  final String email;
  final List<String> favoriteSystems;
  final ProficiencyLevel proficiency;
  final bool isGameMaster;
  final List<MasterModel> campaigns;
  final List<CharacterModel> characters;

  const UserProfileModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.favoriteSystems,
    required this.proficiency,
    this.characters = const [],
    this.isGameMaster = false,
    this.campaigns = const [],
  });

  UserProfileModel copyWith({
    String? id,
    String? userName,
    String? email,
    List<String>? favoriteSystems,
    ProficiencyLevel? proficiency,
    List<CharacterModel>? characters,
    bool? isGameMaster,
    List<MasterModel>? campaigns,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      favoriteSystems: favoriteSystems ?? this.favoriteSystems,
      proficiency: proficiency ?? this.proficiency,
      characters: characters ?? this.characters,
      isGameMaster: isGameMaster ?? this.isGameMaster,
      campaigns: campaigns ?? this.campaigns,
    );
  }

  factory UserProfileModel.fromMap(String id, Map<String, dynamic> map) {
    return UserProfileModel(
      id: id,
      userName: map['name'] ?? '',
      email: map['email'] ?? '',
      isGameMaster: map['role'] == 'master',
      proficiency: ProficiencyLevel.fromString(map['proficiency']),
      favoriteSystems: List<String>.from(map['systems'] ?? []),
      characters: (map['characters'] as List? ?? [])
          .map((c) => CharacterModel.fromMap(c))
          .toList(),
      campaigns: (map['campaigns'] as List? ?? [])
          .map((c) => MasterModel.fromMap(c))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': userName,
      'email': email,
      'role': isGameMaster ? 'master' : 'player',
      'proficiency': proficiency.name,
      'systems': favoriteSystems,
      'characters': characters.map((c) => c.toMap()).toList(),
      'campaigns': campaigns.map((c) => c.toMap()).toList(),
    };
  }
}
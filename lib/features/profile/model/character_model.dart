// lib/features/profile/model/character_model.dart
class CharacterModel {
  final String id;
  final String playerId;
  final String playerName;
  final String name;
  final String characterClass;
  final String system;
  final String bio;
  final String? imagePath;

  const CharacterModel({
    required this.id,
    this.playerId = '',
    this.playerName = '',
    required this.name,
    required this.characterClass,
    this.system = 'Geral',
    required this.bio,
    this.imagePath,
  });

  CharacterModel copyWith({
    String? id,
    String? playerId,
    String? playerName,
    String? name,
    String? characterClass,
    String? system,
    String? bio,
    String? imagePath,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      system: system ?? this.system,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CharacterModel(
      id: docId ?? map['id'] ?? '',
      playerId: map['playerId'] ?? '',
      playerName: map['playerName'] ?? 'Jogador',
      name: map['name'] ?? '',
      characterClass: map['characterClass'] ?? '',
      system: map['system'] ?? 'Geral',
      bio: map['bio'] ?? '',
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'name': name,
      'characterClass': characterClass,
      'system': system,
      'bio': bio,
      'imagePath': imagePath,
    };
  }
}
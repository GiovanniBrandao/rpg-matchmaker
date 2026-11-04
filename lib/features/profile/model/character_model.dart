class CharacterModel {
  final String id;
  final String name;
  final String characterClass;
  final String bio;
  final String? imagePath;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.characterClass,
    required this.bio,
    this.imagePath,
  });

  CharacterModel copyWith({
    String? id,
    String? name,
    String? characterClass,
    String? bio,
    String? imagePath,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      characterClass: characterClass ?? this.characterClass,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      characterClass: map['characterClass'] ?? '',
      bio: map['bio'] ?? '',
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'characterClass': characterClass,
      'bio': bio,
      'imagePath': imagePath,
    };
  }
}
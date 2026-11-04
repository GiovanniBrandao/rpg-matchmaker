class MasterModel {
  final String id;
  final String name;
  final String system;
  final String description;
  final String? imagePath;

  const MasterModel({
    required this.id,
    required this.name,
    required this.system,
    required this.description,
    this.imagePath,
  });

  MasterModel copyWith({
    String? id,
    String? name,
    String? system,
    String? description,
    String? imagePath,
  }) {
    return MasterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      system: system ?? this.system,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory MasterModel.fromMap(Map<String, dynamic> map) {
    return MasterModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      system: map['system'] ?? '',
      description: map['description'] ?? '',
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'system': system,
      'description': description,
      'imagePath': imagePath,
    };
  }
}
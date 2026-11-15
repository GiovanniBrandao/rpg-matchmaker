// lib/features/profile/model/master_model.dart
class MasterModel {
  final String id;
  final String masterId;
  final String masterName;
  final String name;
  final String system;
  final String description;
  final bool isOnline;
  final String? imagePath;

  const MasterModel({
    required this.id,
    this.masterId = '',
    this.masterName = '',
    required this.name,
    required this.system,
    required this.description,
    this.isOnline = true,
    this.imagePath,
  });

  MasterModel copyWith({
    String? id,
    String? masterId,
    String? masterName,
    String? name,
    String? system,
    String? description,
    bool? isOnline,
    String? imagePath,
  }) {
    return MasterModel(
      id: id ?? this.id,
      masterId: masterId ?? this.masterId,
      masterName: masterName ?? this.masterName,
      name: name ?? this.name,
      system: system ?? this.system,
      description: description ?? this.description,
      isOnline: isOnline ?? this.isOnline,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory MasterModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return MasterModel(
      id: docId ?? map['id'] ?? '',
      masterId: map['masterId'] ?? '',
      masterName: map['masterName'] ?? 'Mestre',
      name: map['name'] ?? '',
      system: map['system'] ?? '',
      description: map['description'] ?? '',
      isOnline: map['isOnline'] ?? true,
      imagePath: map['imagePath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'masterId': masterId,
      'masterName': masterName,
      'name': name,
      'system': system,
      'description': description,
      'isOnline': isOnline,
      'imagePath': imagePath,
    };
  }
}
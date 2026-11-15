// lib/features/swipe/model/swipe_item_model.dart
class SwipeItemModel {
  final String id;
  final String title;
  final String system;
  final String location;
  final String desc;
  final String imagePath;
  final double? distanceKm;

  SwipeItemModel({
    required this.id,
    required this.title,
    required this.system,
    required this.location,
    required this.desc,
    required this.imagePath,
    this.distanceKm,
  });
}
// lib/features/swipe/model/swipe_model.dart
class SwipeItemModel {
  final String id;
  final String title;
  final String system;
  final String location;
  final String suggestedVenue;
  final String schedule;
  final String desc;
  final String imagePath;
  final double? distanceKm;

  const SwipeItemModel({
    required this.id,
    required this.title,
    required this.system,
    required this.location,
    required this.desc,
    required this.imagePath,
    this.suggestedVenue = 'Taverna do Dado Dourado (2,4 km)',
    this.schedule = 'Sábados • 19h às 23h',
    this.distanceKm,
  });
}

class RestaurantModel {
  RestaurantModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.active,
    required this.categories,
    required this.averagePreparationMinutes,
    this.coverImageUrl,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final bool active;
  final List<String> categories;
  final int averagePreparationMinutes;
  final String? coverImageUrl;
}

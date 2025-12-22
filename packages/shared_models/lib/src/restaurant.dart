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

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      active: json['active'] as bool? ?? true,
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      averagePreparationMinutes: json['averagePreparationMinutes'] as int? ?? 20,
      coverImageUrl: json['coverImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'active': active,
      'categories': categories,
      'averagePreparationMinutes': averagePreparationMinutes,
      'coverImageUrl': coverImageUrl,
    };
  }
}

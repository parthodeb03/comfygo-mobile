class Destination {
  final int id;
  final String name;
  final String description;
  final String location;
  final String division;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double price;
  final String? bestTimeToVisit;
  final List<String>? activities;
  final double? latitude;
  final double? longitude;
  final bool isFeatured;
  final DateTime createdAt;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.division,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.bestTimeToVisit,
    this.activities,
    this.latitude,
    this.longitude,
    this.isFeatured = false,
    required this.createdAt,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      division: json['division'],
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      bestTimeToVisit: json['best_time_to_visit'],
      activities: json['activities'] != null
          ? List<String>.from(json['activities'])
          : null,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'division': division,
      'images': images,
      'rating': rating,
      'review_count': reviewCount,
      'price': price,
      'best_time_to_visit': bestTimeToVisit,
      'activities': activities,
      'latitude': latitude,
      'longitude': longitude,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

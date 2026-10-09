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
  final List<DestinationActivity>? activities;
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
      activities: json['activities'] == null
          ? null
          : (json['activities'] as List)
                .map(DestinationActivity.fromJson)
                .toList(),
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
      'activities': activities?.map((activity) => activity.toJson()).toList(),
      'latitude': latitude,
      'longitude': longitude,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DestinationActivity {
  final String imageUrl;
  final String name;
  final String type;
  final List<String> startTimes;
  final int rating;
  final double price;

  const DestinationActivity({
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.startTimes,
    required this.rating,
    required this.price,
  });

  factory DestinationActivity.fromJson(dynamic value) {
    if (value is String) {
      return DestinationActivity(
        imageUrl: '',
        name: value,
        type: 'Sightseeing Tour',
        startTimes: const ['9:00 AM', '2:00 PM'],
        rating: 5,
        price: 0,
      );
    }
    final json = Map<String, dynamic>.from(value as Map);
    return DestinationActivity(
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      startTimes: List<String>.from(
        json['startTimes'] ?? json['start_times'] ?? const [],
      ),
      rating: (json['rating'] as num?)?.round() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    'name': name,
    'type': type,
    'startTimes': startTimes,
    'rating': rating,
    'price': price,
  };
}

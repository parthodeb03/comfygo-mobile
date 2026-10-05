class Hotel {
  final int id;
  final String name;
  final String description;
  final String location;
  final String division;
  final String address;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final double pricePerNight;
  final int managerId;
  final String? managerName;
  final List<String> amenities;
  final int totalRooms;
  final int availableRooms;
  final String? phone;
  final String? email;
  final bool isApproved;
  final DateTime createdAt;

  Hotel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.division,
    required this.address,
    required this.images,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.managerId,
    this.managerName,
    required this.amenities,
    required this.totalRooms,
    required this.availableRooms,
    this.phone,
    this.email,
    this.isApproved = true,
    required this.createdAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      division: json['division'],
      address: json['address'],
      images: List<String>.from(json['images'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      managerId: json['manager_id'],
      managerName: json['manager_name'],
      amenities: List<String>.from(json['amenities'] ?? []),
      totalRooms: json['total_rooms'] ?? 0,
      availableRooms: json['available_rooms'] ?? 0,
      phone: json['phone'],
      email: json['email'],
      isApproved: json['is_approved'] ?? true,
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
      'address': address,
      'images': images,
      'rating': rating,
      'review_count': reviewCount,
      'price_per_night': pricePerNight,
      'manager_id': managerId,
      'manager_name': managerName,
      'amenities': amenities,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'phone': phone,
      'email': email,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

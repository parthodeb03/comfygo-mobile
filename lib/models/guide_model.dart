class Guide {
  final int id;
  final int userId;
  final String name;
  final String? profileImage;
  final String? bio;
  final List<String> languages;
  final String specialization;
  final double rating;
  final int reviewCount;
  final int experience;
  final double dailyRate;
  final String? phone;
  final String? email;
  final String? location;
  final bool isApproved;
  final DateTime createdAt;

  Guide({
    required this.id,
    required this.userId,
    required this.name,
    this.profileImage,
    this.bio,
    required this.languages,
    required this.specialization,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.dailyRate,
    this.phone,
    this.email,
    this.location,
    this.isApproved = true,
    required this.createdAt,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      profileImage: json['profile_image'],
      bio: json['bio'],
      languages: List<String>.from(json['languages'] ?? []),
      specialization: json['specialization'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      experience: json['experience'] ?? 0,
      dailyRate: (json['daily_rate'] ?? 0).toDouble(),
      phone: json['phone'],
      email: json['email'],
      location: json['location'],
      isApproved: json['is_approved'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'profile_image': profileImage,
      'bio': bio,
      'languages': languages,
      'specialization': specialization,
      'rating': rating,
      'review_count': reviewCount,
      'experience': experience,
      'daily_rate': dailyRate,
      'phone': phone,
      'email': email,
      'location': location,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

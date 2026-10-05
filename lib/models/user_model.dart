/// User Model - supports Tourist, Guide, Hotel Manager, and Admin roles
enum UserRole { tourist, guide, hotelManager, admin }

class User {
  final int id;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Tourist-specific
  final String? address;
  final String? nationality;

  // Guide-specific
  final String? bio;
  final List<String>? languages;
  final double? rating;
  final int? experience;

  // Hotel Manager-specific
  final int? hotelId;
  final String? hotelName;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.updatedAt,
    this.address,
    this.nationality,
    this.bio,
    this.languages,
    this.rating,
    this.experience,
    this.hotelId,
    this.hotelName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'] ?? '',
      role: _parseRole(json['role']),
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      address: json['address'],
      nationality: json['nationality'],
      bio: json['bio'],
      languages: json['languages'] != null
          ? List<String>.from(json['languages'])
          : null,
      rating: json['rating']?.toDouble(),
      experience: json['experience'],
      hotelId: json['hotel_id'],
      hotelName: json['hotel_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role.name,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'address': address,
      'nationality': nationality,
      'bio': bio,
      'languages': languages,
      'rating': rating,
      'experience': experience,
      'hotel_id': hotelId,
      'hotel_name': hotelName,
    };
  }

  static UserRole _parseRole(String role) {
    switch (role.toLowerCase()) {
      case 'tourist':
        return UserRole.tourist;
      case 'guide':
        return UserRole.guide;
      case 'hotel_manager':
        return UserRole.hotelManager;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.tourist;
    }
  }

  User copyWith({
    int? id,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? address,
    String? nationality,
    String? bio,
    List<String>? languages,
    double? rating,
    int? experience,
    int? hotelId,
    String? hotelName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      bio: bio ?? this.bio,
      languages: languages ?? this.languages,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
    );
  }
}

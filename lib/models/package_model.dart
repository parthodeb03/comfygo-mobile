enum PackageTier { basic, pro, premium, ultimate }

enum PackageStatus { active, expired, cancelled }

class Package {
  final int id;
  final String name;
  final PackageTier tier;
  final double price;
  final String? description;
  final int bookingLimit;
  final double discountPercentage;
  final bool priorityListing;
  final bool featuredListing;
  final bool vipSupport;
  final bool exclusivePackages;
  final DateTime createdAt;

  Package({
    required this.id,
    required this.name,
    required this.tier,
    required this.price,
    this.description,
    required this.bookingLimit,
    required this.discountPercentage,
    this.priorityListing = false,
    this.featuredListing = false,
    this.vipSupport = false,
    this.exclusivePackages = false,
    required this.createdAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      id: json['id'],
      name: json['name'],
      tier: _parseTier(json['tier']),
      price: (json['price'] ?? 0).toDouble(),
      description: json['description'],
      bookingLimit: json['booking_limit'] ?? 0,
      discountPercentage: (json['discount_percentage'] ?? 0).toDouble(),
      priorityListing: json['priority_listing'] ?? false,
      featuredListing: json['featured_listing'] ?? false,
      vipSupport: json['vip_support'] ?? false,
      exclusivePackages: json['exclusive_packages'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tier': tier.name,
      'price': price,
      'description': description,
      'booking_limit': bookingLimit,
      'discount_percentage': discountPercentage,
      'priority_listing': priorityListing,
      'featured_listing': featuredListing,
      'vip_support': vipSupport,
      'exclusive_packages': exclusivePackages,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PackageTier _parseTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'basic':
        return PackageTier.basic;
      case 'pro':
        return PackageTier.pro;
      case 'premium':
        return PackageTier.premium;
      case 'ultimate':
        return PackageTier.ultimate;
      default:
        return PackageTier.basic;
    }
  }

  // Predefined packages
  static List<Package> get predefinedPackages => [
    Package(
      id: 1,
      name: 'Basic',
      tier: PackageTier.basic,
      price: 0,
      description: 'Free tier with basic features',
      bookingLimit: 3,
      discountPercentage: 0,
      createdAt: DateTime.now(),
    ),
    Package(
      id: 2,
      name: 'Pro',
      tier: PackageTier.pro,
      price: 499,
      description: 'Pro tier with priority listing',
      bookingLimit: 10,
      discountPercentage: 5,
      priorityListing: true,
      createdAt: DateTime.now(),
    ),
    Package(
      id: 3,
      name: 'Premium',
      tier: PackageTier.premium,
      price: 999,
      description: 'Premium tier with featured listing',
      bookingLimit: -1, // unlimited
      discountPercentage: 10,
      priorityListing: true,
      featuredListing: true,
      createdAt: DateTime.now(),
    ),
    Package(
      id: 4,
      name: 'Ultimate',
      tier: PackageTier.ultimate,
      price: 1999,
      description: 'Ultimate tier with all features',
      bookingLimit: -1, // unlimited
      discountPercentage: 20,
      priorityListing: true,
      featuredListing: true,
      vipSupport: true,
      exclusivePackages: true,
      createdAt: DateTime.now(),
    ),
  ];
}

class UserPackage {
  final int id;
  final int userId;
  final int packageId;
  final Package package;
  final PackageStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  UserPackage({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.package,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory UserPackage.fromJson(Map<String, dynamic> json) {
    return UserPackage(
      id: json['id'],
      userId: json['user_id'],
      packageId: json['package_id'],
      package: Package.fromJson(json['package']),
      status: _parseStatus(json['status']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'package': package.toJson(),
      'status': status.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PackageStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return PackageStatus.active;
      case 'expired':
        return PackageStatus.expired;
      case 'cancelled':
        return PackageStatus.cancelled;
      default:
        return PackageStatus.active;
    }
  }

  bool get isActive =>
      status == PackageStatus.active && endDate.isAfter(DateTime.now());
}

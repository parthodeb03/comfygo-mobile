class Transport {
  final int id;
  final String name;
  final String type; // bus, car, train, flight
  final String description;
  final String fromLocation;
  final String toLocation;
  final String departureTime;
  final String? arrivalTime;
  final double price;
  final int totalSeats;
  final int availableSeats;
  final List<String> amenities;
  final String? operatorName;
  final String? phone;
  final bool isApproved;
  final DateTime createdAt;

  Transport({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    this.arrivalTime,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.amenities,
    this.operatorName,
    this.phone,
    this.isApproved = true,
    required this.createdAt,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      fromLocation: json['from_location'],
      toLocation: json['to_location'],
      departureTime: json['departure_time'],
      arrivalTime: json['arrival_time'],
      price: (json['price'] ?? 0).toDouble(),
      totalSeats: json['total_seats'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      operatorName: json['operator_name'],
      phone: json['phone'],
      isApproved: json['is_approved'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'from_location': fromLocation,
      'to_location': toLocation,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'price': price,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'amenities': amenities,
      'operator_name': operatorName,
      'phone': phone,
      'is_approved': isApproved,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

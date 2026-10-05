enum BookingStatus { pending, confirmed, cancelled, completed }

enum BookingType { hotel, transport, guide, destination }

class Booking {
  final int id;
  final int touristId;
  final String touristName;
  final BookingType type;
  final BookingStatus status;
  final int itemId;
  final String itemName;
  final DateTime checkIn;
  final DateTime? checkOut;
  final int guests;
  final double totalPrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.touristId,
    required this.touristName,
    required this.type,
    required this.status,
    required this.itemId,
    required this.itemName,
    required this.checkIn,
    this.checkOut,
    required this.guests,
    required this.totalPrice,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      touristId: json['tourist_id'],
      touristName: json['tourist_name'] ?? '',
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      itemId: json['item_id'],
      itemName: json['item_name'] ?? '',
      checkIn: DateTime.parse(json['check_in']),
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'])
          : null,
      guests: json['guests'] ?? 1,
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tourist_id': touristId,
      'tourist_name': touristName,
      'type': type.name,
      'status': status.name,
      'item_id': itemId,
      'item_name': itemName,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'guests': guests,
      'total_price': totalPrice,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static BookingType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return BookingType.hotel;
      case 'transport':
        return BookingType.transport;
      case 'guide':
        return BookingType.guide;
      case 'destination':
        return BookingType.destination;
      default:
        return BookingType.hotel;
    }
  }

  static BookingStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'completed':
        return BookingStatus.completed;
      default:
        return BookingStatus.pending;
    }
  }

  Booking copyWith({
    int? id,
    int? touristId,
    String? touristName,
    BookingType? type,
    BookingStatus? status,
    int? itemId,
    String? itemName,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? totalPrice,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      touristId: touristId ?? this.touristId,
      touristName: touristName ?? this.touristName,
      type: type ?? this.type,
      status: status ?? this.status,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      guests: guests ?? this.guests,
      totalPrice: totalPrice ?? this.totalPrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

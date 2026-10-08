import 'package:equatable/equatable.dart';

/// A review left on a completed booking (one per booking).
class Review extends Equatable {
  final int id;
  final int userId;
  final int bookingId;
  final String itemType;
  final int itemId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.itemType,
    required this.itemId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        bookingId: json['booking_id'] as int,
        itemType: json['item_type'] as String,
        itemId: json['item_id'] as int,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        comment: json['comment'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'booking_id': bookingId,
        'item_type': itemType,
        'item_id': itemId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, userId, bookingId, itemType, itemId, rating, comment, createdAt];
}

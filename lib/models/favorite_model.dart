import 'package:equatable/equatable.dart';

/// DB-backed favorite item. `item_type` is one of: destination, hotel, guide,
/// transport.
class Favorite extends Equatable {
  final int id;
  final int userId;
  final String itemType;
  final int itemId;
  final String? itemName;
  final String? itemImage;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.itemId,
    this.itemName,
    this.itemImage,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        itemType: json['item_type'] as String,
        itemId: json['item_id'] as int,
        itemName: json['item_name'] as String?,
        itemImage: json['item_image'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'item_type': itemType,
        'item_id': itemId,
        'item_name': itemName,
        'item_image': itemImage,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, userId, itemType, itemId, itemName, itemImage, createdAt];
}

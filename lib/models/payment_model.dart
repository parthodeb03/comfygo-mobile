enum PaymentMethod { card, cash }

enum PaymentStatus { pending, completed, failed, refunded }

class Payment {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? cardLastFour;
  final String? notes;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.cardLastFour,
    this.notes,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      userId: json['user_id'],
      amount: (json['amount'] ?? 0).toDouble(),
      method: _parseMethod(json['method']),
      status: _parseStatus(json['status']),
      transactionId: json['transaction_id'],
      cardLastFour: json['card_last_four'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'amount': amount,
      'method': method.name,
      'status': status.name,
      'transaction_id': transactionId,
      'card_last_four': cardLastFour,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static PaymentMethod _parseMethod(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'cash':
        return PaymentMethod.cash;
      default:
        return PaymentMethod.cash;
    }
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }
}

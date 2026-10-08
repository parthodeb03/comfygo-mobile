import 'package:dio/dio.dart';

import '../core/utils/app_logger.dart';
import '../models/models.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Reviews service.
class ReviewService {
  final ApiClient _apiClient;

  ReviewService(this._apiClient);

  /// Leave a review for a *completed* booking.
  Future<Review?> createReview(int bookingId, {required int rating, String? comment}) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/reviews',
        data: {
          'booking_id': bookingId,
          'rating': rating,
          'comment': comment ?? '',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Review.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      AppLogger.error(
        'Error creating review: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }

  /// Public list of reviews for a listing item (e.g. a hotel, destination, guide or transport).
  Future<List<Review>> getReviews({String? itemType, int? itemId}) async {
    try {
      final query = <String, dynamic>{};
      if (itemType != null) query['item_type'] = itemType;
      if (itemId != null) query['item_id'] = itemId;

      final response = await _apiClient.dio.get('/api/v1/reviews', queryParameters: query);
      if (response.statusCode == 200) {
        final data = response.data;
        return (data['items'] as List)
            .map((json) => Review.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      AppLogger.error(
        'Error fetching reviews: ${e.message}',
        e.error,
        e.stackTrace,
      );
      throw apiExceptionFrom(e);
    }
  }
}

import 'package:core/core.dart';
import '../models/dining_model.dart';

class DiningService {
  final BffClient _bffClient;

  DiningService({BffClient? bffClient})
      : _bffClient = bffClient ?? ServiceLocator.instance.get<BffClient>();

  Future<List<DiningItem>> getDinings({String? tripId}) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id;
    final path = effectiveTripId != null ? '/api/v1/dining?tripId=$effectiveTripId' : '/api/v1/dining';
    final response = await _bffClient.get(path);
    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => DiningItem.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<DiningItem?> addDining({
    required String name,
    required String cuisine,
    required String specialty,
    required String address,
    required String reservationTime,
    double rating = 4.8,
    String status = 'planejado',
    String notes = '',
    String? tripId,
  }) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    final response = await _bffClient.post('/api/v1/dining', {
      'name': name,
      'cuisine': cuisine,
      'specialty': specialty,
      'address': address,
      'reservationTime': reservationTime,
      'rating': rating,
      'status': status,
      'notes': notes,
      'tripId': effectiveTripId,
    });
    if (response != null && response['data'] != null) {
      return DiningItem.fromJson(response['data']);
    }
    return null;
  }

  Future<DiningItem?> updateDining({
    required String id,
    required String name,
    required String cuisine,
    required String specialty,
    required String address,
    required String reservationTime,
    double rating = 4.8,
    String status = 'planejado',
    String notes = '',
  }) async {
    final response = await _bffClient.put('/api/v1/dining/$id', {
      'name': name,
      'cuisine': cuisine,
      'specialty': specialty,
      'address': address,
      'reservationTime': reservationTime,
      'rating': rating,
      'status': status,
      'notes': notes,
    });
    if (response != null && response['data'] != null) {
      return DiningItem.fromJson(response['data']);
    }
    return null;
  }

  Future<void> deleteDining(String id) async {
    await _bffClient.delete('/api/v1/dining/$id');
  }

  Future<void> updateStatus(String id, String newStatus) async {
    await _bffClient.patch('/api/v1/dining/$id/status', {'status': newStatus});
  }
}

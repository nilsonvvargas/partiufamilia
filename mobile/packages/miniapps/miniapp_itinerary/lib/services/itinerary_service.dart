import 'package:core/core.dart';
import '../models/itinerary_model.dart';

class ItineraryService {
  final BffClient _bffClient;

  ItineraryService({BffClient? bffClient})
      : _bffClient = bffClient ?? ServiceLocator.instance.get<BffClient>();

  Future<List<ItineraryItem>> getItineraries({String? tripId}) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id;
    final path = effectiveTripId != null ? '/api/v1/itinerary?tripId=$effectiveTripId' : '/api/v1/itinerary';
    final response = await _bffClient.get(path);
    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ItineraryItem.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<ItineraryItem?> addItinerary({
    required String title,
    required int day,
    required String location,
    required String description,
    required String time,
    String? tideTime,
    required String tag,
    required String imageUrl,
    String? date,
    String? tripId,
  }) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    final response = await _bffClient.post('/api/v1/itinerary', {
      'title': title,
      'day': day,
      'location': location,
      'description': description,
      'time': time,
      'tideTime': tideTime,
      'tag': tag,
      'imageUrl': imageUrl,
      'date': date,
      'tripId': effectiveTripId,
      'status': 'planned',
    });
    if (response != null && response['data'] != null) {
      return ItineraryItem.fromJson(response['data']);
    }
    return null;
  }

  Future<ItineraryItem?> updateItinerary({
    required String id,
    required String title,
    required int day,
    required String location,
    required String description,
    required String time,
    String? tideTime,
    required String tag,
    required String imageUrl,
    String? date,
    String? status,
  }) async {
    final response = await _bffClient.put('/api/v1/itinerary/$id', {
      'title': title,
      'day': day,
      'location': location,
      'description': description,
      'time': time,
      'tideTime': tideTime,
      'tag': tag,
      'imageUrl': imageUrl,
      'date': date,
      'status': status,
    });
    if (response != null && response['data'] != null) {
      return ItineraryItem.fromJson(response['data']);
    }
    return null;
  }

  Future<void> deleteItinerary(String id) async {
    await _bffClient.delete('/api/v1/itinerary/$id');
  }

  Future<void> updateStatus(String id, String newStatus) async {
    await _bffClient.patch('/api/v1/itinerary/$id/status', {'status': newStatus});
  }
}

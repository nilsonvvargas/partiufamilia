import 'package:core/core.dart';
import '../models/stay_model.dart';

class StayService {
  final BffClient _bffClient;

  StayService({BffClient? bffClient})
      : _bffClient = bffClient ?? ServiceLocator.instance.get<BffClient>();

  Future<StayModel?> getStay({String? tripId}) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id;
    final path = effectiveTripId != null ? '/api/v1/stay?tripId=$effectiveTripId' : '/api/v1/stay';
    final response = await _bffClient.get(path);
    if (response != null && response['data'] != null) {
      return StayModel.fromJson(response['data']);
    }
    return null;
  }

  Future<StayModel?> updateStay({
    required String name,
    required String address,
    required String neighborhood,
    required String checkIn,
    required String checkOut,
    required String bookingCode,
    required String wifiNetwork,
    required String wifiPassword,
    required String hostContact,
    String? tripId,
  }) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    final response = await _bffClient.put('/api/v1/stay', {
      'name': name,
      'address': address,
      'neighborhood': neighborhood,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'bookingCode': bookingCode,
      'wifiNetwork': wifiNetwork,
      'wifiPassword': wifiPassword,
      'hostContact': hostContact,
      'tripId': effectiveTripId,
    });

    if (response != null && response['data'] != null) {
      return StayModel.fromJson(response['data']);
    }
    return null;
  }
}

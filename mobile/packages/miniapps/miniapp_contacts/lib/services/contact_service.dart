import 'package:core/core.dart';
import '../models/contact_model.dart';

class ContactService {
  final BffClient _bffClient;

  ContactService({BffClient? bffClient})
      : _bffClient = bffClient ?? ServiceLocator.instance.get<BffClient>();

  Future<List<ContactItem>> getContacts({String? tripId}) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id;
    final path = effectiveTripId != null ? '/api/v1/contacts?tripId=$effectiveTripId' : '/api/v1/contacts';
    final response = await _bffClient.get(path);
    if (response != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => ContactItem.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<ContactItem?> addContact({
    required String name,
    required String role,
    required String phone,
    String? whatsapp,
    String? location,
    String? notes,
    String? tripId,
  }) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    final response = await _bffClient.post('/api/v1/contacts', {
      'name': name,
      'role': role,
      'phone': phone,
      'whatsapp': whatsapp ?? phone,
      'location': location ?? 'Maceió, AL',
      'notes': notes ?? '',
      'tripId': effectiveTripId,
    });

    if (response != null && response['data'] != null) {
      return ContactItem.fromJson(response['data']);
    }
    return null;
  }

  Future<ContactItem?> updateContact({
    required String id,
    required String name,
    required String role,
    required String phone,
    String? whatsapp,
    String? location,
    String? notes,
  }) async {
    final response = await _bffClient.put('/api/v1/contacts/$id', {
      'name': name,
      'role': role,
      'phone': phone,
      'whatsapp': whatsapp ?? phone,
      'location': location,
      'notes': notes,
    });

    if (response != null && response['data'] != null) {
      return ContactItem.fromJson(response['data']);
    }
    return null;
  }

  Future<void> deleteContact(String id) async {
    await _bffClient.delete('/api/v1/contacts/$id');
  }
}

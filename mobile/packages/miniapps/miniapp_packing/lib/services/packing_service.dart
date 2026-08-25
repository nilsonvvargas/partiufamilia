import 'package:core/core.dart';
import '../models/packing_model.dart';

class PackingService {
  final BffClient _bffClient;

  PackingService({BffClient? bffClient})
      : _bffClient = bffClient ?? ServiceLocator.instance.get<BffClient>();

  Future<({List<PackingItem> items, PackingStats stats})> getPackingList({String? tripId}) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id;
    final path = effectiveTripId != null ? '/api/v1/packing?tripId=$effectiveTripId' : '/api/v1/packing';
    final response = await _bffClient.get(path);
    if (response != null && response['data'] != null) {
      final itemsData = response['data']['items'] as List? ?? [];
      final statsData = response['data']['stats'] as Map<String, dynamic>? ?? {};

      final items = itemsData.map((e) => PackingItem.fromJson(e)).toList();
      final stats = PackingStats.fromJson(statsData);

      return (items: items, stats: stats);
    }
    return (items: <PackingItem>[], stats: PackingStats(packedCount: 0, totalCount: 0, progressPercentage: 0));
  }

  Future<void> togglePacked(String id) async {
    await _bffClient.patch('/api/v1/packing/$id/toggle', {});
  }

  Future<PackingItem?> addItem({
    required String name,
    required String category,
    String member = 'Todos',
    int quantity = 1,
    String? tripId,
  }) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    final response = await _bffClient.post('/api/v1/packing', {
      'name': name,
      'category': category,
      'member': member,
      'quantity': quantity,
      'tripId': effectiveTripId,
    });

    if (response != null && response['data'] != null) {
      return PackingItem.fromJson(response['data']);
    }
    return null;
  }

  Future<PackingItem?> updateItem({
    required String id,
    required String name,
    required String category,
    String? member,
    int quantity = 1,
    bool? isPacked,
  }) async {
    final response = await _bffClient.put('/api/v1/packing/$id', {
      'name': name,
      'category': category,
      if (member != null) 'member': member,
      'quantity': quantity,
      if (isPacked != null) 'isPacked': isPacked,
    });

    if (response != null && response['data'] != null) {
      return PackingItem.fromJson(response['data']);
    }
    return null;
  }


  Future<void> deleteItem(String id) async {
    await _bffClient.delete('/api/v1/packing/$id');
  }
}

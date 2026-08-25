import 'package:core/core.dart';
import '../models/expense_model.dart';

class ExpenseService {
  final BffClient _bffClient;

  ExpenseService({BffClient? bffClient})
      : _bffClient = bffClient ?? ServiceLocator.instance.get<BffClient>();

  Future<({List<ExpenseItem> items, ExpensesSummary summary})> getExpenses({String? tripId}) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id;
    final path = effectiveTripId != null ? '/api/v1/expenses?tripId=$effectiveTripId' : '/api/v1/expenses';
    final response = await _bffClient.get(path);
    if (response != null && response['data'] != null) {
      final itemsData = response['data']['items'] as List? ?? [];
      final summaryData = response['data']['summary'] as Map<String, dynamic>? ?? {};

      final items = itemsData.map((e) => ExpenseItem.fromJson(e)).toList();
      final summary = ExpensesSummary.fromJson(summaryData);

      return (items: items, summary: summary);
    }
    return (items: <ExpenseItem>[], summary: ExpensesSummary(totalAmount: 0, totalItems: 0, byCategory: {}));
  }

  Future<ExpenseItem?> addExpense({
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    List<String>? splitWith,
    String? date,
    String? tripId,
  }) async {
    final effectiveTripId = tripId ?? TripContext.instance.activeTrip?.id ?? 'trip-maceio';
    final response = await _bffClient.post('/api/v1/expenses', {
      'title': title,
      'amount': amount,
      'category': category,
      'paidBy': paidBy,
      'splitWith': splitWith ?? [paidBy],
      'date': date,
      'tripId': effectiveTripId,
    });

    if (response != null && response['data'] != null) {
      return ExpenseItem.fromJson(response['data']);
    }
    return null;
  }

  Future<ExpenseItem?> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    List<String>? splitWith,
    String? date,
  }) async {
    final response = await _bffClient.put('/api/v1/expenses/$id', {
      'title': title,
      'amount': amount,
      'category': category,
      'paidBy': paidBy,
      'splitWith': splitWith,
      'date': date,
    });

    if (response != null && response['data'] != null) {
      return ExpenseItem.fromJson(response['data']);
    }
    return null;
  }

  Future<void> deleteExpense(String id) async {
    await _bffClient.delete('/api/v1/expenses/$id');
  }
}

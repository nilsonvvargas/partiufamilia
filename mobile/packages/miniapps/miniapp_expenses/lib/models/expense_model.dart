class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final List<String> splitWith;
  final String date;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.splitWith,
    required this.date,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount'].toString()) ?? 0.0,
      category: json['category'] ?? 'Outros',
      paidBy: json['paidBy'] ?? json['paid_by'] ?? 'Nilson',
      splitWith: json['splitWith'] is List
          ? List<String>.from(json['splitWith'])
          : json['split_with'] is List
              ? List<String>.from(json['split_with'])
              : ['Nilson'],
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'paidBy': paidBy,
        'splitWith': splitWith,
        'date': date,
      };
}

class ExpensesSummary {
  final double totalAmount;
  final int totalItems;
  final Map<String, double> byCategory;

  ExpensesSummary({
    required this.totalAmount,
    required this.totalItems,
    required this.byCategory,
  });

  factory ExpensesSummary.fromJson(Map<String, dynamic> json) {
    final rawCat = json['byCategory'] as Map<String, dynamic>? ?? {};
    final mapped = rawCat.map((k, v) => MapEntry(k, (v as num).toDouble()));

    return ExpensesSummary(
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : 0.0,
      totalItems: json['totalItems'] ?? 0,
      byCategory: mapped,
    );
  }
}

class PackingItem {
  final String id;
  final String name;
  final String category;
  final bool isPacked;
  final int quantity;

  PackingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.isPacked,
    required this.quantity,
  });

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'Geral',
      isPacked: json['isPacked'] ?? json['is_packed'] ?? false,
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'isPacked': isPacked,
        'quantity': quantity,
      };
}

class PackingStats {
  final int packedCount;
  final int totalCount;
  final int progressPercentage;

  PackingStats({
    required this.packedCount,
    required this.totalCount,
    required this.progressPercentage,
  });

  factory PackingStats.fromJson(Map<String, dynamic> json) {
    return PackingStats(
      packedCount: json['packedCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      progressPercentage: json['progressPercentage'] ?? 0,
    );
  }
}

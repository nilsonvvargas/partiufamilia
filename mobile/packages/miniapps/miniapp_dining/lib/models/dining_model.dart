class DiningItem {
  final String id;
  final String name;
  final String cuisine;
  final String specialty;
  final String address;
  final String reservationTime;
  final double rating;
  final String status;
  final String notes;

  DiningItem({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.specialty,
    required this.address,
    required this.reservationTime,
    required this.rating,
    required this.status,
    required this.notes,
  });

  factory DiningItem.fromJson(Map<String, dynamic> json) {
    return DiningItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cuisine: json['cuisine'] ?? '',
      specialty: json['specialty'] ?? '',
      address: json['address'] ?? '',
      reservationTime: json['reservationTime'] ?? json['reservation_time'] ?? '',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse(json['rating'].toString()) ?? 4.8,
      status: json['status'] ?? 'planejado',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cuisine': cuisine,
        'specialty': specialty,
        'address': address,
        'reservationTime': reservationTime,
        'rating': rating,
        'status': status,
        'notes': notes,
      };
}

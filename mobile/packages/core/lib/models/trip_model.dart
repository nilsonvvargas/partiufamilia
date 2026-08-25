class TripModel {
  final String id;
  final String? ownerId;
  final String shareCode;
  final String title;
  final String destination;
  final String state;
  final String startDate;
  final String endDate;
  final String tripDates;
  final String imageUrl;
  final String status;
  final String tag;
  final double budget;
  final int totalDays;

  TripModel({
    required this.id,
    this.ownerId,
    this.shareCode = '',
    required this.title,
    required this.destination,
    required this.state,
    required this.startDate,
    required this.endDate,
    required this.tripDates,
    required this.imageUrl,
    required this.status,
    required this.tag,
    required this.budget,
    required this.totalDays,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? json['owner_id'],
      shareCode: json['shareCode'] ?? json['share_code'] ?? '',
      title: json['title'] ?? '',
      destination: json['destination'] ?? '',
      state: json['state'] ?? 'Brasil',
      startDate: json['startDate'] ?? json['start_date'] ?? '',
      endDate: json['endDate'] ?? json['end_date'] ?? '',
      tripDates: json['tripDates'] ?? json['trip_dates'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      status: json['status'] ?? 'planned',
      tag: json['tag'] ?? 'Planejada',
      budget: (json['budget'] is num) ? (json['budget'] as num).toDouble() : double.tryParse(json['budget'].toString()) ?? 3000.0,
      totalDays: json['totalDays'] is int ? json['totalDays'] : int.tryParse(json['totalDays'].toString()) ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'shareCode': shareCode,
        'title': title,
        'destination': destination,
        'state': state,
        'startDate': startDate,
        'endDate': endDate,
        'tripDates': tripDates,
        'imageUrl': imageUrl,
        'status': status,
        'tag': tag,
        'budget': budget,
        'totalDays': totalDays,
      };
}

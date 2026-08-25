class ItineraryItem {
  final String id;
  final int day;
  final String date;
  final String title;
  final String location;
  final String description;
  final String time;
  final String? tideTime;
  final String status;
  final String tag;
  final String imageUrl;

  ItineraryItem({
    required this.id,
    required this.day,
    required this.date,
    required this.title,
    required this.location,
    required this.description,
    required this.time,
    this.tideTime,
    required this.status,
    required this.tag,
    required this.imageUrl,
  });

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'] ?? '',
      day: json['day'] is int ? json['day'] : int.tryParse(json['day'].toString()) ?? 1,
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? '',
      tideTime: json['tideTime'] ?? json['tide_time'],
      status: json['status'] ?? 'planned',
      tag: json['tag'] ?? 'Passeio',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'date': date,
        'title': title,
        'location': location,
        'description': description,
        'time': time,
        'tideTime': tideTime,
        'status': status,
        'tag': tag,
        'imageUrl': imageUrl,
      };
}

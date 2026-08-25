class StayModel {
  final String id;
  final String name;
  final String address;
  final String neighborhood;
  final String checkIn;
  final String checkOut;
  final String bookingCode;
  final String wifiNetwork;
  final String wifiPassword;
  final List<String> rules;
  final List<String> amenities;
  final String hostContact;

  StayModel({
    required this.id,
    required this.name,
    required this.address,
    required this.neighborhood,
    required this.checkIn,
    required this.checkOut,
    required this.bookingCode,
    required this.wifiNetwork,
    required this.wifiPassword,
    required this.rules,
    required this.amenities,
    required this.hostContact,
  });

  factory StayModel.fromJson(Map<String, dynamic> json) {
    return StayModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      neighborhood: json['neighborhood'] ?? '',
      checkIn: json['checkIn'] ?? json['check_in'] ?? '',
      checkOut: json['checkOut'] ?? json['check_out'] ?? '',
      bookingCode: json['bookingCode'] ?? json['booking_code'] ?? '',
      wifiNetwork: json['wifiNetwork'] ?? json['wifi_network'] ?? '',
      wifiPassword: json['wifiPassword'] ?? json['wifi_password'] ?? '',
      rules: json['rules'] is List ? List<String>.from(json['rules']) : [],
      amenities: json['amenities'] is List ? List<String>.from(json['amenities']) : [],
      hostContact: json['hostContact'] ?? json['host_contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'neighborhood': neighborhood,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'bookingCode': bookingCode,
        'wifiNetwork': wifiNetwork,
        'wifiPassword': wifiPassword,
        'rules': rules,
        'amenities': amenities,
        'hostContact': hostContact,
      };
}

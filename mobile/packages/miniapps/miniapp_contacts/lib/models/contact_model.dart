class ContactItem {
  final String id;
  final String name;
  final String role;
  final String phone;
  final String whatsapp;
  final String location;
  final String notes;

  ContactItem({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    required this.whatsapp,
    required this.location,
    required this.notes,
  });

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'Contato',
      phone: json['phone'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
        'whatsapp': whatsapp,
        'location': location,
        'notes': notes,
      };
}

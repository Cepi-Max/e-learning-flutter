class User {
  final int id;
  final String name;
  final String email;
  final String lokasi;
  final String phone_number;
  final String role;


  User({
    required this.id,
    required this.name,
    required this.email,
    required this.lokasi,
    required this.phone_number,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'nama tidak ada',
      email: json['email'] ?? 'email tidak ada',
      lokasi: json['lokasi'] ?? 'lokasi tidak ada.',
      phone_number: json['phone_number'] ?? 'nomer hp tidak ada.',
      role: json['role'] ?? 'role tidak ada',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'lokasi': lokasi,
      'phone_number': phone_number,
      'role': role,
    };
  }
}

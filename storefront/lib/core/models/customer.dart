class Customer {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;

  const Customer({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as String,
        email: j['email'] as String,
        firstName: j['first_name'] as String? ?? '',
        lastName: j['last_name'] as String? ?? '',
        phone: j['phone'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      };
}

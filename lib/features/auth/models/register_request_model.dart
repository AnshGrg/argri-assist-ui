class RegisterRequestModel {
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? city;
  final String password;
  final String passwordConfirm;

  RegisterRequestModel({
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.city,
    required this.password,
    required this.passwordConfirm,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'username': username,
      'email': email,
      'password': password,
      'password_confirm': passwordConfirm,
    };
    if (firstName != null && firstName!.isNotEmpty) map['first_name'] = firstName;
    if (lastName != null && lastName!.isNotEmpty) map['last_name'] = lastName;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) map['phone_number'] = phoneNumber;
    if (city != null && city!.isNotEmpty) map['city'] = city;
    return map;
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) {
    return RegisterRequestModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneNumber: json['phone_number'],
      city: json['city'],
      password: json['password'] ?? '',
      passwordConfirm: json['password_confirm'] ?? '',
    );
  }
}

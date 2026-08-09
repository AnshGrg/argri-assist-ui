class UserProfileUpdateModel {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? city;

  UserProfileUpdateModel({
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.city,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (email != null) map['email'] = email;
    if (phoneNumber != null) map['phone_number'] = phoneNumber;
    if (city != null) map['city'] = city;
    return map;
  }

  factory UserProfileUpdateModel.fromJson(Map<String, dynamic> json) {
    return UserProfileUpdateModel(
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      city: json['city'],
    );
  }
}

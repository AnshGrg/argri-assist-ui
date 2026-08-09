class UserProfileDetailsModel {
  final String? phoneNumber;
  final String? city;
  final String? createdAt;

  UserProfileDetailsModel({
    this.phoneNumber,
    this.city,
    this.createdAt,
  });

  factory UserProfileDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserProfileDetailsModel(
      phoneNumber: json['phone_number'],
      city: json['city'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'city': city,
      'created_at': createdAt,
    };
  }
}

class UserProfileModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isStaff;
  final String dateJoined;
  final UserProfileDetailsModel? profile;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isStaff,
    required this.dateJoined,
    this.profile,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : username;
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isStaff: json['is_staff'] ?? false,
      dateJoined: json['date_joined'] ?? '',
      profile: json['profile'] != null
          ? UserProfileDetailsModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'date_joined': dateJoined,
      'profile': profile?.toJson(),
    };
  }
}

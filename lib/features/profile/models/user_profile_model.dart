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
    final data = (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return UserProfileModel(
      id: data['id'] as int? ?? 0,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      isStaff: data['is_staff'] as bool? ?? false,
      dateJoined: data['date_joined'] as String? ?? '',
      profile: data['profile'] != null && data['profile'] is Map<String, dynamic>
          ? UserProfileDetailsModel.fromJson(data['profile'] as Map<String, dynamic>)
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

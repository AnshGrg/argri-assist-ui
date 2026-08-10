class AuthTokensModel {
  final String access;
  final String refresh;
  final String? username;
  final String? email;
  final int? userId;

  AuthTokensModel({
    required this.access,
    required this.refresh,
    this.username,
    this.email,
    this.userId,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      access: json['access'] ?? json['access_token'] ?? '',
      refresh: json['refresh'] ?? json['refresh_token'] ?? '',
      username: json['username'] as String?,
      email: json['email'] as String?,
      userId: json['user_id'] is int ? json['user_id'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (userId != null) 'user_id': userId,
    };
  }
}

class AuthTokensModel {
  final String access;
  final String refresh;

  AuthTokensModel({
    required this.access,
    required this.refresh,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      access: json['access'] ?? json['access_token'] ?? '',
      refresh: json['refresh'] ?? json['refresh_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}

class RefreshTokenRequestModel {
  final String refresh;

  RefreshTokenRequestModel({
    required this.refresh,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
    };
  }

  factory RefreshTokenRequestModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequestModel(
      refresh: json['refresh'] ?? '',
    );
  }
}

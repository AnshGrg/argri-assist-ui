class LogoutRequestModel {
  final String refresh;

  LogoutRequestModel({
    required this.refresh,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
    };
  }

  factory LogoutRequestModel.fromJson(Map<String, dynamic> json) {
    return LogoutRequestModel(
      refresh: json['refresh'] ?? '',
    );
  }
}

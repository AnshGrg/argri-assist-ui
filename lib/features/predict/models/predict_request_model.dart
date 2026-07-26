class PredictRequestModel {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double latitude;
  final double longitude;
  final String season;

  const PredictRequestModel({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.latitude,
    required this.longitude,
    required this.season,
  });

  Map<String, dynamic> toJson() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'latitude': latitude,
      'longitude': longitude,
      'season': season,
    };
  }
}

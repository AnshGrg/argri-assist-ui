class PredictRequestModel {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double latitude;
  final double longitude;
  final String season;
  final double? temperature;
  final double? humidity;
  final double? rainfall;

  const PredictRequestModel({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.latitude,
    required this.longitude,
    required this.season,
    this.temperature,
    this.humidity,
    this.rainfall,
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
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (rainfall != null) 'rainfall': rainfall,
    };
  }
}

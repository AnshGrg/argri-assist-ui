class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.agriassist.example.com/v1';

  // Endpoint routes placeholders
  static const String getWeather = '$baseUrl/weather';
  static const String getPredictionHistory = '$baseUrl/predictions/history';
  static const String predictCrop = '$baseUrl/predict/crop';
  static const String predictFertilizer = '$baseUrl/predict/fertilizer';
}

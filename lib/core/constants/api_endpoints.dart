class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://api.agriassist.example.com/v1';

  // Endpoint routes placeholders
  static const String getWeather = '$baseUrl/weather';
  static const String getPredictionHistory = '$baseUrl/predictions/history';
  static const String predictCrop = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/crop/';
  static const String predictFertilizer = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/fertilizer/';
  static const String getCrops = 'https://unknotted-unknown-heat.ngrok-free.dev/api/recommendation/crops/';
}

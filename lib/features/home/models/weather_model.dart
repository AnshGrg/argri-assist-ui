class WeatherModel {
  final double temperature;
  final String condition;
  final String location;
  final double humidity;

  const WeatherModel({
    required this.temperature,
    required this.condition,
    required this.location,
    required this.humidity,
  });

  // Factory methods for future API mapping
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] as num).toDouble(),
      condition: json['condition'] as String,
      location: json['location'] as String,
      humidity: (json['humidity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'location': location,
      'humidity': humidity,
    };
  }
}

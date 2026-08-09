class ClimateCardModel {
  final String city;
  final double averageTemperature;
  final double averageHumidity;
  final double averageRainfall;

  ClimateCardModel({
    required this.city,
    required this.averageTemperature,
    required this.averageHumidity,
    required this.averageRainfall,
  });

  factory ClimateCardModel.fromJson(Map<String, dynamic> json) {
    return ClimateCardModel(
      city: json['city'] ?? '',
      averageTemperature: (json['average_temperature'] as num?)?.toDouble() ?? 0.0,
      averageHumidity: (json['average_humidity'] as num?)?.toDouble() ?? 0.0,
      averageRainfall: (json['average_rainfall'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'average_temperature': averageTemperature,
      'average_humidity': averageHumidity,
      'average_rainfall': averageRainfall,
    };
  }
}

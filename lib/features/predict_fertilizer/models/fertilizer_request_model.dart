class FertilizerRequestModel {
  final String cropType;
  final String soilType;
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double temperature;
  final double humidity;
  final double rainfall;

  const FertilizerRequestModel({
    required this.cropType,
    required this.soilType,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.temperature,
    required this.humidity,
    required this.rainfall,
  });

  Map<String, dynamic> toJson() {
    return {
      'cropType': cropType,
      'soilType': soilType,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': ph,
      'temperature': temperature,
      'humidity': humidity,
      'rainfall': rainfall,
    };
  }
}

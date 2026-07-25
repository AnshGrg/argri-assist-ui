class PredictRequestModel {
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double temperature;
  final double rainfall;
  final double ph;

  const PredictRequestModel({
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.temperature,
    required this.rainfall,
    required this.ph,
  });

  Map<String, dynamic> toJson() {
    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'temperature': temperature,
      'rainfall': rainfall,
      'ph': ph,
    };
  }
}

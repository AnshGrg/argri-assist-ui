class HistoryItemModel {
  final String id;
  final String cropName;
  final double confidenceScore;
  final String date;
  
  // Input parameters
  final double nitrogen;
  final double phosphorus;
  final double potassium;
  final double ph;
  final double temperature;
  final double rainfall;

  // Fertilizer Recommendation (optional, if user went through fertilizer flow)
  final String? recommendedFertilizer;
  final String? fertilizerDosage;

  const HistoryItemModel({
    required this.id,
    required this.cropName,
    required this.confidenceScore,
    required this.date,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.ph,
    required this.temperature,
    required this.rainfall,
    this.recommendedFertilizer,
    this.fertilizerDosage,
  });

  HistoryItemModel copyWith({
    String? recommendedFertilizer,
    String? fertilizerDosage,
  }) {
    return HistoryItemModel(
      id: id,
      cropName: cropName,
      confidenceScore: confidenceScore,
      date: date,
      nitrogen: nitrogen,
      phosphorus: phosphorus,
      potassium: potassium,
      ph: ph,
      temperature: temperature,
      rainfall: rainfall,
      recommendedFertilizer: recommendedFertilizer ?? this.recommendedFertilizer,
      fertilizerDosage: fertilizerDosage ?? this.fertilizerDosage,
    );
  }
}

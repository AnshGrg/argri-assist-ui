class FertilizerResultModel {
  final String recommendedFertilizer;
  final String dosage;
  final List<String> instructions;
  final List<String> notes;

  const FertilizerResultModel({
    required this.recommendedFertilizer,
    required this.dosage,
    required this.instructions,
    required this.notes,
  });

  factory FertilizerResultModel.fromJson(Map<String, dynamic> json) {
    return FertilizerResultModel(
      recommendedFertilizer: json['recommendedFertilizer'] as String,
      dosage: json['dosage'] as String,
      instructions: List<String>.from(json['instructions'] as List),
      notes: List<String>.from(json['notes'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedFertilizer': recommendedFertilizer,
      'dosage': dosage,
      'instructions': instructions,
      'notes': notes,
    };
  }
}

import '../models/fertilizer_request_model.dart';
import '../models/fertilizer_result_model.dart';

abstract class FertilizerRepo {
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request);
}

class MockFertilizerRepo implements FertilizerRepo {
  @override
  Future<FertilizerResultModel> predictFertilizer(FertilizerRequestModel request) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return the recommended details matching the wireframe: Urea, 120 kg/ha
    return const FertilizerResultModel(
      recommendedFertilizer: 'Urea',
      dosage: '120 kg/ha',
      instructions: [
        '50% at basal stage',
        '50% at top dressing (30-35 days)',
      ],
      notes: [
        'Ensure adequate irrigation after application.',
        'Avoid application before heavy rainfall.',
      ],
    );
  }
}

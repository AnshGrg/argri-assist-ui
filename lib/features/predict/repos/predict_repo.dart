import '../models/predict_request_model.dart';
import '../models/prediction_result_model.dart';

abstract class PredictRepo {
  Future<PredictionResultModel> predictCrop(PredictRequestModel request);
}

class MockPredictRepo implements PredictRepo {
  @override
  Future<PredictionResultModel> predictCrop(PredictRequestModel request) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Return Maize as in the wireframe result with a 92% confidence score
    return const PredictionResultModel(
      cropName: 'Maize',
      confidenceScore: 0.92,
      description: 'Maize is well-suited for your soil conditions and current weather.',
      imageUrl: 'assets/images/maize.png',
    );
  }
}

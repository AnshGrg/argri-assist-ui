import '../../features/history/models/history_item_model.dart';

class MockDatabase {
  MockDatabase._();

  static final List<HistoryItemModel> historyList = [
    const HistoryItemModel(
      id: '1',
      cropName: 'Maize',
      confidenceScore: 0.92,
      date: '20 May 2024 • 10:30 AM',
      nitrogen: 120.0,
      phosphorus: 60.0,
      potassium: 80.0,
      ph: 6.7,
      temperature: 27.6,
      rainfall: 82.4,
      recommendedFertilizer: 'Urea',
      fertilizerDosage: '120 kg/ha',
    ),
    const HistoryItemModel(
      id: '2',
      cropName: 'Wheat',
      confidenceScore: 0.88,
      date: '15 May 2024 • 09:15 AM',
      nitrogen: 100.0,
      phosphorus: 50.0,
      potassium: 75.0,
      ph: 6.5,
      temperature: 22.4,
      rainfall: 70.2,
      recommendedFertilizer: 'DAP',
      fertilizerDosage: '100 kg/ha',
    ),
    const HistoryItemModel(
      id: '3',
      cropName: 'Rice',
      confidenceScore: 0.95,
      date: '10 May 2024 • 08:45 AM',
      nitrogen: 140.0,
      phosphorus: 80.0,
      potassium: 90.0,
      ph: 6.0,
      temperature: 30.2,
      rainfall: 120.5,
      recommendedFertilizer: 'NPK 19:19:19',
      fertilizerDosage: '150 kg/ha',
    ),
    const HistoryItemModel(
      id: '4',
      cropName: 'Cotton',
      confidenceScore: 0.85,
      date: '05 May 2024 • 11:20 AM',
      nitrogen: 90.0,
      phosphorus: 40.0,
      potassium: 60.0,
      ph: 7.2,
      temperature: 29.1,
      rainfall: 60.8,
      recommendedFertilizer: 'MOP',
      fertilizerDosage: '80 kg/ha',
    ),
    const HistoryItemModel(
      id: '5',
      cropName: 'Groundnut',
      confidenceScore: 0.90,
      date: '01 May 2024 • 07:50 AM',
      nitrogen: 70.0,
      phosphorus: 35.0,
      potassium: 50.0,
      ph: 6.8,
      temperature: 28.5,
      rainfall: 55.4,
      recommendedFertilizer: 'SSP',
      fertilizerDosage: '90 kg/ha',
    ),
  ];

  static void addRecord(HistoryItemModel record) {
    historyList.insert(0, record);
  }
}

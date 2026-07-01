import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:farm_frontend/views/health_view.dart'; // TreatmentRecord modeli için

class HealthNotifier extends AsyncNotifier<void> {
  final DioClient _dioClient = DioClient();

  @override
  Future<void> build() async {}

  // Backend'den (getCowRecords) belirli bir ineğin tedavi geçmişini getirir
  Future<List<TreatmentRecord>> getTreatments(String cowId) async {
    try {
      final response = await _dioClient.dio.get('health-records/$cowId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map(
              (json) => TreatmentRecord(
                name: json['description'] ?? json['type'],
                date: DateTime.parse(json['treatment_date']),
                cost: double.tryParse(json['cost'].toString()) ?? 0.0,
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Tedavi geçmişi alınamadı: $e');
      return [];
    }
  }

  // Backend'e (store) yeni bir tedavi/aşı kaydı ekler
  Future<bool> addTreatment({
    required String cowId,
    required String type,
    required String description,
    required double cost,
    int? calfCount, // YENİ EKLENDİ
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'health-records',
        data: {
          'cow_id': cowId,
          'type': type,
          'description': description,
          'cost': cost,
          'calf_count': calfCount, // YENİ EKLENDİ
          'treatment_date': DateTime.now().toIso8601String(),
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Tedavi ekleme hatası: $e');
      return false;
    }
  }
}

// Provider'ı UI'a sunuyoruz
final healthProvider = AsyncNotifierProvider<HealthNotifier, void>(
  () => HealthNotifier(),
);

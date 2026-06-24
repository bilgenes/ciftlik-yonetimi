import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class DailyLogService {
  final DioClient _dioClient = DioClient();

  // En son girilen günlük kaydı getirir (Otomatik doldur butonuna basılınca)
  Future<Map<String, dynamic>?> getLastLog() async {
    try {
      final response = await _dioClient.dio.get('daily-logs/last');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Son kayıt alınamadı: $e');
      return null;
    }
  }

  // Bugünün verilerini kaydeder
  Future<bool> saveTodayLog({
    required String date,
    required double milk,
    required double feed,
    required double silage,
    required double straw,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'daily-logs',
        data: {
          'log_date': date,
          'milk_produced': milk,
          'feed_consumed': feed,
          'silage_consumed': silage,
          'straw_consumed': straw,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      if (e is DioException) {
        print('Kayıt Hatası Detayı: ${e.response?.data}');
      }
      return false;
    }
  }
}

// Servisi UI tarafına sunuyoruz
final dailyLogProvider = Provider<DailyLogService>((ref) => DailyLogService());

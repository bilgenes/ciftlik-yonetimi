import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';

class SettingsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  final DioClient _dioClient = DioClient();

  @override
  Future<Map<String, dynamic>> build() async {
    try {
      final response = await _dioClient.dio.get('settings');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Ayarlar yüklenemedi: $e');
      return {};
    }
  }

  // Tüm form verilerini tek seferde backend'e POST atar
  Future<bool> saveSettings(Map<String, dynamic> settingsData) async {
    try {
      final response = await _dioClient.dio.post(
        'settings',
        data: settingsData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        state = AsyncData(settingsData); // Uygulama arayüzünü canlı günceller
        return true;
      }
      return false;
    } catch (e) {
      print('Ayarlar kaydedilemedi: $e');
      return false;
    }
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Map<String, dynamic>>(() {
      return SettingsNotifier();
    });

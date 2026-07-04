import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:farm_frontend/models/cow.dart';
import 'package:dio/dio.dart';

// 1. ASYNC NOTIFIER (Hem Veri Çeker Hem de Değiştirir)
class CowNotifier extends AsyncNotifier<List<Cow>> {
  final DioClient _dioClient = DioClient();

  // İlk açılışta verileri çek
  @override
  Future<List<Cow>> build() async {
    return _fetchCows();
  }

  // Sadece Listeyi Getiren Yardımcı Fonksiyon
  Future<List<Cow>> _fetchCows() async {
    try {
      // YENİ: Uygulama açıldığında arka planda sütleri ekleme motorunu tetikler
      await _dioClient.dio.get('system/daily-check');

      final response = await _dioClient.dio.get('cows');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Cow.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('İnek verileri alınamadı: $e');
    }
  }

  // Yeni İnek Ekleme (POST)
  Future<bool> addCow(Cow newCow) async {
    try {
      final response = await _dioClient.dio.post('cows', data: newCow.toJson());

      if (response.statusCode == 201) {
        // Eklenen yeni ineği backend'den gelen ID ile beraber modele çevir
        final addedCow = Cow.fromJson(response.data['cow']);

        // UI'daki listeyi güncelle (Tekrar API'ye istek atmadan lokalde ekler)
        state = AsyncData([...state.value ?? [], addedCow]);
        return true;
      }
      return false;
    } catch (e) {
      print('Ekleme Hatası: $e');
      if (e is DioException) {
        print(
          'Hata Detayı: ${e.response?.data}',
        ); // Laravel Validation hatalarını görmek için
      }
      return false;
    }
  }

  // İnek Güncelleme (PUT)
  Future<bool> updateCow(Cow updatedCow) async {
    try {
      final response = await _dioClient.dio.put(
        'cows/${updatedCow.id}', // Backend'de muhtemelen update route'u böyledir
        data: updatedCow.toJson(),
      );

      if (response.statusCode == 200) {
        // UI Listesinde o ineği bul ve değiştir
        state = AsyncData([
          for (final cow in state.value ?? [])
            if (cow.id == updatedCow.id) updatedCow else cow,
        ]);
        return true;
      }
      return false;
    } catch (e) {
      print('Güncelleme Hatası: $e');
      return false;
    }
  }

  // İneği Tamamen Silme (DELETE)
  Future<bool> deleteCow(String cowId) async {
    try {
      final response = await _dioClient.dio.delete('cows/$cowId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        state = AsyncData(
          (state.value ?? []).where((c) => c.id != cowId).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Silme Hatası: $e');
      return false;
    }
  }
}

// 2. PROVIDER'I DIŞARI AÇIYORUZ
final cowProvider = AsyncNotifierProvider<CowNotifier, List<Cow>>(() {
  return CowNotifier();
});

// 3. TEK BİR İNEK SORGULAMA (QR / Barkod İçin)
final cowByTagProvider = FutureProvider.family<Cow?, String>((ref, tag) async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.get('cows/by-tag/$tag');
    if (response.statusCode == 200) {
      return Cow.fromJson(response.data);
    }
    return null;
  } catch (e) {
    throw Exception('Hayvan bilgisi bulunamadı.');
  }
});

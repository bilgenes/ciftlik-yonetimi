import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';

// --- VERİ MODELLERİ ---
class AnalysisData {
  final Map<String, int> herd;
  final Map<String, double> performance;

  AnalysisData({required this.herd, required this.performance});

  factory AnalysisData.fromJson(Map<String, dynamic> json) {
    return AnalysisData(
      herd: {
        'Toplam İnek': json['herd']['total'] ?? 0,
        'Süt Verenler': json['herd']['milk_cows'] ?? 0,
        'Hamileler': json['herd']['pregnant'] ?? 0,
        'Düveler': json['herd']['heifers'] ?? 0,
        'Danalar': json['herd']['bulls'] ?? 0,
        'Buzağılar': json['herd']['calves'] ?? 0,
      },
      performance: {
        'milk_produced':
            double.tryParse(json['performance']['milk_produced'].toString()) ??
            0.0,
        'feed_used':
            double.tryParse(json['performance']['feed_used'].toString()) ?? 0.0,
        'straw_used':
            double.tryParse(json['performance']['straw_used'].toString()) ??
            0.0,
        'silage_used':
            double.tryParse(json['performance']['silage_used'].toString()) ??
            0.0,
        'birth_count':
            double.tryParse(json['performance']['birth_count'].toString()) ??
            0.0,
        'sick_count':
            double.tryParse(json['performance']['sick_count'].toString()) ??
            0.0,
        'slaughter_count':
            double.tryParse(
              json['performance']['slaughter_count'].toString(),
            ) ??
            0.0,
        'treatment_count':
            double.tryParse(
              json['performance']['treatment_count'].toString(),
            ) ??
            0.0,
      },
    );
  }
}

// --- FUTURE PROVIDER FAMILY (En Temiz ve Hatasız Yöntem) ---
// Filtre parametresine (String) göre API'den canlı veriyi çeker
final analysisProvider = FutureProvider.family<AnalysisData, String>((
  ref,
  filter,
) async {
  final dioClient = DioClient();

  try {
    final response = await dioClient.dio.get(
      'analysis',
      queryParameters: {'time_filter': filter},
    );

    if (response.statusCode == 200) {
      return AnalysisData.fromJson(response.data);
    }
    throw Exception('Analiz verisi yüklenemedi');
  } catch (e) {
    print('Analiz Hatası: $e');
    // Hata durumunda uygulamanın çökmemesi için sıfırlanmış veri dönüyoruz
    return AnalysisData(
      herd: {
        'Toplam İnek': 0,
        'Süt Verenler': 0,
        'Hamileler': 0,
        'Düveler': 0,
        'Danalar': 0,
        'Buzağılar': 0,
      },
      performance: {},
    );
  }
});

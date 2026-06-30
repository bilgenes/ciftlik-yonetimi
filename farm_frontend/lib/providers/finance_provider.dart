import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:dio/dio.dart';

// --- FİNANS VERİ MODELİ ---
class FinancialTransaction {
  String id;
  String title;
  String type;
  String category;
  double amount;
  DateTime date;

  FinancialTransaction({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id']?.toString() ?? '',
      title: json['description'] ?? 'İşlem',
      type: json['transaction_type'] == 'gelir' ? 'Gelir' : 'Gider',
      category: json['category'] ?? 'Diğer',
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      // SAAT SORUNU ÇÖZÜMÜ: transaction_date yerine direkt oluşturulma anını (created_at) alıyoruz
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }
}

// --- PROVIDER SINIFI ---
class FinanceNotifier extends AsyncNotifier<List<FinancialTransaction>> {
  final DioClient _dioClient = DioClient();

  @override
  Future<List<FinancialTransaction>> build() async {
    return _fetchTransactions();
  }

  Future<List<FinancialTransaction>> _fetchTransactions() async {
    try {
      final response = await _dioClient.dio.get('finances');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => FinancialTransaction.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Finans verisi çekme hatası: $e');
      return [];
    }
  }

  Future<bool> addTransaction({
    required String type,
    required String category,
    required double amount,
    required String description,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'finances',
        data: {
          'transaction_type': type,
          'category': category,
          'amount': amount,
          'description': description,
          'transaction_date': DateTime.now().toIso8601String(),
        },
      );
      if (response.statusCode == 201) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sellMilk({required double liters, required double price}) async {
    try {
      final response = await _dioClient.dio.post(
        'finances/milk-sale',
        data: {'liters': liters, 'price': price},
      );
      if (response.statusCode == 201) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> slaughterCow({
    required String cowId,
    required String tagNumber,
    required double price,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'finances/slaughter',
        data: {'cow_id': cowId, 'tag_number': tagNumber, 'price': price},
      );
      if (response.statusCode == 201) {
        ref.invalidateSelf();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final financeProvider =
    AsyncNotifierProvider<FinanceNotifier, List<FinancialTransaction>>(() {
      return FinanceNotifier();
    });

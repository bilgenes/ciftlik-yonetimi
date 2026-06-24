import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:dio/dio.dart';

// --- FİNANS VERİ MODELİ ---
class FinancialTransaction {
  String id;
  String title; // Backend'de 'description'
  String type; // Backend'de 'gelir' veya 'gider'
  String category;
  double amount;
  DateTime date; // Backend'de 'transaction_date'

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
      date: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
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

  // Tüm işlemleri getir (GET)
  Future<List<FinancialTransaction>> _fetchTransactions() async {
    try {
      final response = await _dioClient.dio.get('finances');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Yeniden eskiye doğru sıralamak için listeyi döndürüyoruz (Eğer backend sıralamadıysa)
        return data
            .map((json) => FinancialTransaction.fromJson(json))
            .toList()
            .reversed
            .toList();
      }
      return [];
    } catch (e) {
      print('Finans verisi çekme hatası: $e');
      return [];
    }
  }

  // Yeni gelir/gider ekle (POST)
  Future<bool> addTransaction({
    required String type, // 'gelir' veya 'gider'
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
        // İşlem başarılıysa ekranı anında güncellemek için listeye ekliyoruz
        final newTransaction = FinancialTransaction.fromJson(
          response.data['transaction'],
        );
        state = AsyncData([newTransaction, ...?state.value]);
        return true;
      }
      return false;
    } catch (e) {
      if (e is DioException) {
        print('Finans Ekleme Hatası: ${e.response?.data}');
      }
      return false;
    }
  }
}

final financeProvider =
    AsyncNotifierProvider<FinanceNotifier, List<FinancialTransaction>>(() {
      return FinanceNotifier();
    });

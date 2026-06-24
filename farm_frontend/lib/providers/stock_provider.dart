import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';

// --- MODELLER ---
class StockTransactionModel {
  String id;
  String productName;
  double amount;
  String unit;
  double cost;
  DateTime date;
  String type;

  StockTransactionModel({
    required this.id,
    required this.productName,
    required this.amount,
    required this.unit,
    required this.cost,
    required this.date,
    required this.type,
  });

  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    String pName = json['item_name']?.toString() ?? 'Ürün';
    pName = pName.isNotEmpty
        ? pName[0].toUpperCase() + pName.substring(1).toLowerCase()
        : pName;

    // Birim Belirleme Mantığı
    String unitStr = 'Kg';
    if (pName == 'Süt') unitStr = 'Litre';
    if (pName == 'Saman') unitStr = 'Balya';

    return StockTransactionModel(
      id: json['id']?.toString() ?? '',
      productName: pName,
      amount: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0.0,
      unit: unitStr,
      cost: double.tryParse(json['total_price']?.toString() ?? '0') ?? 0.0,
      date: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : DateTime.now(),
      type: json['transaction_type'] == 'in' ? 'Alım/Üretim' : 'Tüketim',
    );
  }
}

class StockData {
  final Map<String, double> currentStocks;
  final List<StockTransactionModel> transactions;
  StockData({required this.currentStocks, required this.transactions});
}

// --- ASYNC NOTIFIER PROVIDER ---
class StockNotifier extends AsyncNotifier<StockData> {
  final DioClient _dioClient = DioClient();

  @override
  Future<StockData> build() async {
    return _fetchStocks();
  }

  Future<StockData> _fetchStocks() async {
    try {
      final response = await _dioClient.dio.get('stocks');
      if (response.statusCode == 200) {
        final data = response.data;

        Map<String, double> stocks = {
          'Süt':
              double.tryParse(
                data['current_stocks']['Süt']?.toString() ?? '0',
              ) ??
              0.0,
          'Yem':
              double.tryParse(
                data['current_stocks']['Yem']?.toString() ?? '0',
              ) ??
              0.0,
          'Saman':
              double.tryParse(
                data['current_stocks']['Saman']?.toString() ?? '0',
              ) ??
              0.0,
          'Silaj':
              double.tryParse(
                data['current_stocks']['Silaj']?.toString() ?? '0',
              ) ??
              0.0,
        };

        List<StockTransactionModel> txs = [];
        if (data['transactions'] != null) {
          txs = (data['transactions'] as List)
              .map((t) => StockTransactionModel.fromJson(t))
              .toList();
        }

        return StockData(currentStocks: stocks, transactions: txs);
      }
      throw Exception('Stok yüklenemedi');
    } catch (e) {
      print('Stok Hatası: $e');
      return StockData(
        currentStocks: {'Süt': 0, 'Yem': 0, 'Saman': 0, 'Silaj': 0},
        transactions: [],
      );
    }
  }

  // API'ye Stok Ekleme İsteği
  Future<bool> addStock({
    required String itemName,
    required double quantity,
    required double price,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        'stocks/purchase',
        data: {
          'item_name': itemName,
          'quantity': quantity,
          'total_price': price,
          'transaction_date': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ref.invalidateSelf(); // Verileri baştan çeker ve arayüzü günceller
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final stockProvider = AsyncNotifierProvider<StockNotifier, StockData>(
  () => StockNotifier(),
);

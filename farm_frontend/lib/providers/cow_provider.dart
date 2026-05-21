import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:farm_frontend/models/cow.dart';

final cowProvider = FutureProvider<List<Cow>>((ref) async {
  final dioClient = DioClient();
  try {
    final response = await dioClient.dio.get('cows');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Cow.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    throw Exception('İnek verileri alınamadı: $e');
  }
});

// A provider to fetch a single cow by tag
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

import 'package:farm_frontend/core/network/dio_client.dart';
import 'package:farm_frontend/core/network/secure_storage_service.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final _storageService = SecureStorageService();
  final _dioClient = DioClient();

  Future<bool> hasToken() async {
    String? token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        'login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        await _storageService.saveToken(response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Giriş Hatası: $e');
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dioClient.dio.post(
        'register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201 && response.data['token'] != null) {
        await _storageService.saveToken(response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Kayıt Hatası: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (await hasToken()) {
        await _dioClient.dio.post('logout');
      }
    } catch (e) {
      debugPrint('Backend çıkış hatası: $e');
    } finally {
      await _storageService.deleteToken();
    }
  }
}

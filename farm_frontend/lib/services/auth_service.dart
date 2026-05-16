import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  // DİKKAT: Kendi bilgisayarının IPv4 adresini buraya yazmalısın!
  final String baseUrl = 'http://10.96.252.5:8000/api';

  // Depoda token var mı?
  Future<bool> hasToken() async {
    String? token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  // Backend'e giriş isteği atma
  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/login',
        data: {'email': email, 'password': password},
      );

      // Laravel bize 200 Başarılı kodu ve token döndüyse:
      if (response.statusCode == 200 && response.data['token'] != null) {
        // Token'ı telefonun güvenli kasasına kaydet
        await _storage.write(key: 'auth_token', value: response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Giriş Hatası: $e');
      return false; // Hata durumunda giriş başarısız sayılır
    }
  }

  // AuthService sınıfının içine ekle:
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201 && response.data['token'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Kayıt Hatası: $e');
      return false;
    }
  }

  // Çıkış Yapma Metodu
  Future<void> logout() async {
    try {
      // 1. İsteğe bağlı: Backend'e de çıkış yaptığımızı bildirebiliriz
      String? token = await _storage.read(key: 'auth_token');
      if (token != null) {
        await _dio.post(
          '$baseUrl/logout',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } catch (e) {
      print('Backend çıkış hatası: $e');
    } finally {
      // 2. Her durumda cihazdaki token'ı sil (En önemlisi bu)
      await _storage.delete(key: 'auth_token');
    }
  }
}

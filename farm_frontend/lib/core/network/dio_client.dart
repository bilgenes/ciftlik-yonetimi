import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import 'error_handler.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8000/api/', // Android emülatör için localhost
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      ErrorHandlerInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ), // Geliştirme aşamasında loglamak için
    ]);
  }
}

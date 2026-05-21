import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorHandlerInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'Bilinmeyen bir hata oluştu.';
    
    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Bağlantı zaman aşımına uğradı. Lütfen internetinizi kontrol edin.';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'Sunucuya bağlanılamadı.';
    } else if (err.response != null) {
      switch (err.response?.statusCode) {
        case 401:
          errorMessage = 'Oturumunuzun süresi doldu. Lütfen tekrar giriş yapın.';
          // Burada ileride Event bus veya global context ile login sayfasına yönlendirme eklenebilir.
          break;
        case 403:
          errorMessage = 'Bu işlemi yapmaya yetkiniz yok.';
          break;
        case 404:
          errorMessage = 'İstenen veri bulunamadı.';
          break;
        case 422:
          errorMessage = 'Gönderilen veriler geçersiz.';
          break;
        case 500:
          errorMessage = 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
          break;
        default:
          errorMessage = err.response?.data['message'] ?? errorMessage;
      }
    }

    debugPrint('API Hata: $errorMessage');
    
    // Hatayı UI katmanına anlamlı bir mesajla iletiyoruz
    err = err.copyWith(message: errorMessage);
    super.onError(err, handler);
  }
}

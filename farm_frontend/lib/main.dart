import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:farm_frontend/services/notification_service.dart';
import 'views/splash_screen.dart'; // Splash ekranını dahil ettik
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // Flutter motorunun tam çalıştığından emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase başlatma (JSON dosyaları eklendiğinde çalışacak)
  try {
    await Firebase.initializeApp();
    await NotificationService().init();
  } catch (e) {
    debugPrint('Firebase başlatılamadı: $e');
  }

  // Türkçe tarih formatı için gerekli dil verilerini başlatıyoruz
  await initializeDateFormatting('tr_TR', null);

  runApp(const ProviderScope(child: FarmApp()));
}

class FarmApp extends StatelessWidget {
  const FarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern Çiftlik',
      debugShowCheckedModeBanner: false,

      // TÜRKÇE DİL DESTEĞİ BURADA DEVREYE GİRİYOR
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'), // Uygulamayı zorla Türkçe yapar
      ],
      locale: const Locale('tr', 'TR'),
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryGreen,
          secondary: AppColors.strawYellow,
          error: AppColors.barnRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
        ),
        // main.dart içindeki ilgili kısım böyle olmalı:
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Uygulama artık buradan başlayacak
    );
  }
}

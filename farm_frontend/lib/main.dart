import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'views/splash_screen.dart'; // Splash ekranını dahil ettik

void main() async {
  // Flutter motorunun tam çalıştığından emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // Türkçe tarih formatı için gerekli dil verilerini başlatıyoruz
  await initializeDateFormatting('tr_TR', null);

  runApp(const FarmApp());
}

class FarmApp extends StatelessWidget {
  const FarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çiftlik Yönetimi',
      debugShowCheckedModeBanner: false,
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

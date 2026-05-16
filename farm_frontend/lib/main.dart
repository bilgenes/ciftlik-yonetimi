import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'views/splash_screen.dart'; // Splash ekranını dahil ettik

void main() {
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
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Uygulama artık buradan başlayacak
    );
  }
}

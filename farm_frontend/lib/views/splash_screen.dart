import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Uygulama çok hızlı açılırsa logo görünmeden geçer,
    // şık durması için 2 saniyelik yapay bir bekleme koyuyoruz.
    await Future.delayed(const Duration(seconds: 2));

    final authService = AuthService();
    bool isLoggedIn = await authService.hasToken();

    // Flutter'da sayfa değiştirirken "sayfa hala ekranda mı" kontrolü yapmak best practice'dir.
    if (!mounted) return;

    if (isLoggedIn) {
      // Token var, Ana Menüye git ve geri dönüşü kapat (pushReplacement)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Token yok, Login'e git
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryGreen, // Arka plan yeşil
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Şimdilik Flutter'ın hazır traktör/çiftlik ikonunu koyalım
            Icon(Icons.agriculture, size: 100, color: AppColors.white),
            SizedBox(height: 20),
            Text(
              'Çiftlik Yönetimi',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              color: AppColors.white,
            ), // Dönen yükleme animasyonu
          ],
        ),
      ),
    );
  }
}

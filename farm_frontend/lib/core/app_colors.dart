import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFDFDFD);
  static const Color white = Colors.white;
  static const Color black = Color(0xFF2D2D2D);

  static const Color primaryGreen = Color(0xFF43A047); // Canlı Yeşil
  static const Color secondaryPink = Color(0xFFF06292); // Tatlı Pembe
  static const Color strawYellow = Color(0xFFFFD54F); // Saman Sarısı
  static const Color barnRed = Color(0xFFC62828); // Ahır Kırmızısı

  // Renk Geçişleri (Gradients) için
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

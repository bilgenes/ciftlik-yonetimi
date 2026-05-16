import 'package:flutter/material.dart';

class AppColors {
  // Temel Renkler
  static const Color background = Color(0xFFF4F7F6);
  static const Color white = Colors.white;
  static const Color black = Color(0xFF1A1A1A);

  // Canlı ve Tematik Renkler
  static const Color primaryGreen = Color(0xFF43A047);
  static const Color secondaryPink = Color(0xFFF06292);
  static const Color strawYellow = Color(0xFFFFB300);
  static const Color barnRed = Color(0xFFB71C1C);

  // Zengin Renk Geçişleri (Kartlar İçin)
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFC2185B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFCA28), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blackGradient = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

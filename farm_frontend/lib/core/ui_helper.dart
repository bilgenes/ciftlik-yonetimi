import 'package:flutter/material.dart';

class UiHelper {
  // Uygulama genelindeki tüm alt pencereleri (BottomSheet) bu fonksiyon açacak
  static void showPremiumBottomSheet({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavye için ekranı kaydırılabilir yapar
      useSafeArea: true, // Telefon tuşlarıyla çakışmayı ENGELLER
      backgroundColor: Colors.transparent, // Arka plan siyahlığını siler
      builder: (context) => child,
    );
  }
}

import 'package:flutter/material.dart';

class UiHelper {
  static void showPremiumBottomSheet({
    required BuildContext context,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        bottom: true, // KESİN ÇÖZÜM: Alt sistem tuşlarından korur
        child: Padding(
          // KESİN ÇÖZÜM: Klavye açıldığında içeriği yukarı iter
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: child,
        ),
      ),
    );
  }
}

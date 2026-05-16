import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          'Genel Bakış',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontFamily: 'Comfortaa',
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Sistem durumları ve anlık operasyonel veriler.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 30),

        // 4 Farklı Renk Geçişini Birleştiren Dolu Kartlar
        Row(
          children: [
            Expanded(
              child: _buildGradientCard(
                'Toplam Hayvan',
                '42 Baş',
                Icons.grass,
                AppColors.greenGradient,
              ),
            ), // Yeşil
            const SizedBox(width: 15),
            Expanded(
              child: _buildGradientCard(
                'Anlık Süt Verimi',
                '450 L',
                Icons.water_drop_rounded,
                AppColors.yellowGradient,
              ),
            ), // Sarı
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildGradientCard(
                'Kritik Alarmlar',
                '2 Adet',
                Icons.notifications_active_rounded,
                AppColors.redGradient,
              ),
            ), // Kırmızı
            const SizedBox(width: 15),
            Expanded(
              child: _buildGradientCard(
                'Veteriner Görevi',
                '5 İşlem',
                Icons.health_and_safety,
                AppColors.blackGradient,
              ),
            ), // Siyah
          ],
        ),

        const SizedBox(height: 40),

        const Text(
          'Hızlı Operasyonlar',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 15),

        // İşlem baloncuklarında renkleri karıştırıyoruz
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildActionChip(
                'Süt Kaydı Ekle',
                Icons.add_circle_outline,
                AppColors.strawYellow,
              ),
              _buildActionChip(
                'Hayvan Girişi',
                Icons.add_box_outlined,
                AppColors.primaryGreen,
              ),
              _buildActionChip(
                'Veteriner Sevk',
                Icons.medical_services_outlined,
                AppColors.secondaryPink,
              ),
              _buildActionChip(
                'Stok Düş',
                Icons.remove_circle_outline,
                AppColors.barnRed,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientCard(
    String title,
    String value,
    IconData icon,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, Color borderColor) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

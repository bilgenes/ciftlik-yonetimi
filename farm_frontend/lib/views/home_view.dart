import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/cow_provider.dart';

// 1. Riverpod ConsumerStatelessWidget yapısına geçiş yaptık
class HomeView extends ConsumerWidget {
  final Function(int) onNavigate;

  const HomeView({super.key, required this.onNavigate});

  // --- UI YARDIMCILARI ---
  // Ufak Kategori Rozetleri
  Widget _buildCountBadge(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Hızlı Erişim Kartları
  Widget _buildQuickAccessCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.black, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: AppColors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Canlı İnek Listesini cowProvider Üzerinden Dinliyoruz
    final cowAsyncValue = ref.watch(cowProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: cowAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, stack) =>
            Center(child: Text('Veriler yüklenirken hata oluştu: $err')),
        data: (cows) {
          // 3. Veritabanından gelen inekleri kategorilerine göre anlık hesaplıyoruz
          final totalCows = cows.where((c) => c.status == 'Aktif').length;
          final milkCows = cows
              .where(
                (c) => c.status == 'Aktif' && c.category == 'Süt Veren İnekler',
              )
              .length;
          final pregnantCows = cows
              .where(
                (c) => c.status == 'Aktif' && c.category == 'Hamile İnekler',
              )
              .length;
          final heifers = cows
              .where((c) => c.status == 'Aktif' && c.category == 'Düveler')
              .length;
          final bulls = cows
              .where((c) => c.status == 'Aktif' && c.category == 'Danalar')
              .length;
          final calves = cows
              .where((c) => c.status == 'Aktif' && c.category == 'Buzağılar')
              .length;

          return ListView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 40 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // --- 1. NEŞELİ KARŞILAMA BÖLÜMÜ ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '👋 Günaydın!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Enes Çiftliğine\nHoş Geldin...',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comfortaa',
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.strawYellow.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.strawYellow,
                              width: 2,
                            ),
                          ),
                          child: const Text(
                            'Ne Yapmak İstersin?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.black, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🚜', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // --- 2. SÜRÜ DURUMU (Canlı Özet) ---
              const Text(
                'Kısa Sürü Özeti',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 15),

              // Büyük Toplam İnek Kartı (Artık Canlı!)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.blackGradient,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kayıtlı Canlı Sayısı',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          totalCows.toString(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColors.primaryGreen,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Alt Kategoriler Yatay Liste (Artık Canlı!)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCountBadge(
                      'Süt Veren',
                      milkCows,
                      AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 10),
                    _buildCountBadge(
                      'Hamile',
                      pregnantCows,
                      AppColors.secondaryPink,
                    ),
                    const SizedBox(width: 10),
                    _buildCountBadge('Düve', heifers, AppColors.strawYellow),
                    const SizedBox(width: 10),
                    _buildCountBadge('Dana', bulls, AppColors.black),
                    const SizedBox(width: 10),
                    _buildCountBadge('Buzağı', calves, AppColors.barnRed),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- 3. HIZLI ERİŞİM BUTONLARI ---
              const Text(
                'Hızlı Erişim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 15),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: [
                  _buildQuickAccessCard(
                    'İneklerim',
                    'Tüm Sürüyü Yönet',
                    Icons.grass_rounded,
                    AppColors.secondaryPink,
                    () => onNavigate(2),
                  ),
                  _buildQuickAccessCard(
                    'Günlük Sayfam',
                    'Rasyon ve Süt',
                    Icons.edit_note_rounded,
                    AppColors.strawYellow,
                    () => onNavigate(3),
                  ),
                  _buildQuickAccessCard(
                    'Sağlık Durumu',
                    'Tedavi ve Aşılar',
                    Icons.medical_services_rounded,
                    AppColors.barnRed,
                    () => onNavigate(4),
                  ),
                  _buildQuickAccessCard(
                    'Finans',
                    'Gelir & Gider',
                    Icons.payments_rounded,
                    AppColors.primaryGreen,
                    () => onNavigate(6),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

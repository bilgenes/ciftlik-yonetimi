import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class DailyLogView extends StatefulWidget {
  const DailyLogView({super.key});

  @override
  State<DailyLogView> createState() => _DailyLogViewState();
}

class _DailyLogViewState extends State<DailyLogView> {
  // Veri Kontrolcüleri (Controllers)
  final _milkCtrl = TextEditingController();
  final _feedCtrl = TextEditingController();
  final _strawCtrl = TextEditingController();
  final _silageCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isDataFetched = false; // "Son veriyi al" butonuna basıldı mı?

  // --- SAHTE VERİ GETİRME (Backend'den En Son Girilen Gün Gelecek) ---
  Future<void> _fetchLastLog() async {
    setState(() => _isLoading = true);

    // Gerçekte API'ye gidip gelme süresi simülasyonu
    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      // Örnek: Sistemdeki en son veriyi kutulara dolduruyoruz
      _milkCtrl.text = '450';
      _feedCtrl.text = '120';
      _strawCtrl.text = '45';
      _silageCtrl.text = '300';

      _isDataFetched = true;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Son girilen veriler başarıyla kopyalandı!'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // --- BUGÜNÜ KAYDETME ---
  void _saveTodayLog() {
    if (_milkCtrl.text.isEmpty ||
        _feedCtrl.text.isEmpty ||
        _strawCtrl.text.isEmpty ||
        _silageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun!'),
          backgroundColor: AppColors.barnRed,
        ),
      );
      return;
    }

    // TODO: Backend'e POST atılacak
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Günlük veriler başarıyla kaydedildi!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat(
      'dd MMMM yyyy',
      'tr_TR',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // BAŞLIK VE TARİH
          Row(
            children: [
              Container(
                width: 6,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Günlük Rapor',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: 'Comfortaa',
                    ),
                  ),
                  Text(
                    todayDate,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.black.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // AKILLI "SON VERİYİ AL" BUTONU (Saman Sarısı)
          InkWell(
            onTap: _isLoading ? null : _fetchLastLog,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.yellowGradient,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.black, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.black,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.black,
                            size: 28,
                          ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Otomatik Doldur',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comfortaa',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isDataFetched
                              ? 'Son veriler eklendi. Düzenleyebilirsiniz.'
                              : 'En son girilen günün verilerini kopyala.',
                          style: TextStyle(
                            color: AppColors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- 1. KART: ÜRETİM (Yeşil Odaklı) ---
          _buildSectionCard(
            title: 'Süt Üretimi',
            icon: Icons.water_drop_rounded,
            iconColor: AppColors.primaryGreen,
            child: _buildPremiumInput(
              label: 'Toplam Süt',
              suffix: 'Litre',
              icon: Icons.scale_rounded,
              controller: _milkCtrl,
              borderColor: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 25),

          // --- 2. KART: TÜKETİM / MALİYET (Kırmızı Odaklı) ---
          _buildSectionCard(
            title: 'Tüketim (Rasyon)',
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.barnRed,
            child: Column(
              children: [
                _buildPremiumInput(
                  label: 'Hazır Yem',
                  suffix: 'Kg',
                  icon: Icons.shopping_bag_rounded,
                  controller: _feedCtrl,
                  borderColor: AppColors.barnRed,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _buildPremiumInput(
                        label: 'Saman',
                        suffix: 'Kg',
                        icon: Icons.grass_rounded,
                        controller: _strawCtrl,
                        borderColor: AppColors.strawYellow,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildPremiumInput(
                        label: 'Silaj',
                        suffix: 'Kg',
                        icon: Icons.eco_rounded,
                        controller: _silageCtrl,
                        borderColor: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // --- KAYDET BUTONU ---
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 3,
                  ), // Siyah üzerine yeşil kontür çok şık durur
                ),
                elevation: 8,
              ),
              onPressed: _saveTodayLog,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: AppColors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'GÜNÜ KAYDET',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontFamily: 'Comfortaa',
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Altın Standart: Bölüm Kartı Tasarımı
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.black,
          width: 3,
        ), // Premium Siyah Çerçeve
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          child, // İçeriğe (Inputlara) ayrılan alan
        ],
      ),
    );
  }

  // Şık ve Birimli Input Tasarımı
  Widget _buildPremiumInput({
    required String label,
    required String suffix,
    required IconData icon,
    required TextEditingController controller,
    required Color borderColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.black.withOpacity(0.6),
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: AppColors.black.withOpacity(0.7)),
        suffixText: suffix, // Kutu içindeki birim (Örn: Kg, Litre)
        suffixStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
          fontSize: 16,
        ),
        filled: true,
        fillColor: AppColors.background,
        // Normal durumda siyah çerçeve, tıklanınca ilgili modülün rengiyle (Yeşil, Sarı, Kırmızı) parlar
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: borderColor, width: 3),
        ),
      ),
    );
  }
}

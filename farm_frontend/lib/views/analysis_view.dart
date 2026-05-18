import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

class AnalysisView extends StatefulWidget {
  const AnalysisView({super.key});

  @override
  State<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  // Zaman Filtreleri
  final List<String> _timeFilters = [
    'Günlük',
    'Haftalık',
    'Aylık',
    'Yıllık',
    'Tarih Seç',
  ];
  String _selectedFilter = 'Aylık';
  String _customDateText = '';

  // --- SABİT VERİLER (Şu Anki Sürü Durumu) ---
  final Map<String, int> _currentHerd = {
    'Toplam İnek': 142,
    'Süt Verenler': 85,
    'Hamileler': 20,
    'Düveler': 15,
    'Danalar': 10,
    'Buzağılar': 12,
  };

  // --- DİNAMİK VERİLER (Zaman filtresine göre değişecek sahte veriler) ---
  double _milkProduced = 12500;
  double _feedUsed = 4500;
  double _strawUsed = 300;
  double _silageUsed = 8500;

  int _birthCount = 4;
  int _sickCount = 2;
  int _slaughterCount = 1;
  int _treatmentCount = 5;

  // --- GEÇMİŞ İŞLEMLER MOCK VERİSİ (EKLENECEK KISIM) ---
  final List<Map<String, dynamic>> _recentEvents = [
    {
      'title': 'TR-1122 Tedavi Edildi',
      'desc': 'Mastit için Antibiyotik uygulandı.',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'icon': Icons.medical_services_rounded,
      'color': AppColors.primaryGreen,
    },
    {
      'title': 'TR-3344 Doğum Yaptı',
      'desc': '2 adet sağlıklı buzağı sisteme eklendi.',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.child_care_rounded,
      'color': AppColors.strawYellow,
    },
    {
      'title': 'TR-5566 Hastalandı',
      'desc': 'Şap teşhisi konuldu.',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.sick_rounded,
      'color': AppColors.barnRed,
    },
    {
      'title': 'TR-9988 Kesime Gönderildi',
      'desc': '₺85.000 gelir finansa aktarıldı.',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'icon': Icons.content_cut_rounded,
      'color': AppColors.black,
    },
  ];

  // Seçilen filtreye göre ekrandaki rakamları değiştiren animasyonlu fonksiyon
  void _updateDynamicData(String filter) {
    setState(() {
      _selectedFilter = filter;
      _customDateText = '';

      // Filtreye göre sahte oranlar (Gerçekte API'den gelecek)
      double multiplier = 1.0;
      if (filter == 'Günlük') multiplier = 0.03;
      if (filter == 'Haftalık') multiplier = 0.25;
      if (filter == 'Aylık') multiplier = 1.0;
      if (filter == 'Yıllık') multiplier = 12.0;

      _milkProduced = 12500 * multiplier;
      _feedUsed = 4500 * multiplier;
      _strawUsed = 300 * multiplier;
      _silageUsed = 8500 * multiplier;

      _birthCount = (4 * multiplier).ceil();
      _sickCount = (2 * multiplier).ceil();
      _slaughterCount = (1 * multiplier).ceil();
      _treatmentCount = (5 * multiplier).ceil();
    });
  }

  // --- PREMIUM VE TÜRKÇE TARİH SEÇİCİ ---
  Future<void> _pickPremiumDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.black,
              onPrimary: AppColors.white,
              surface: AppColors.background,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: AppColors.background,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = 'Tarih Seç';
        _customDateText =
            '${DateFormat('dd MMM', 'tr_TR').format(picked.start)} - ${DateFormat('dd MMM yyyy', 'tr_TR').format(picked.end)}';

        // Tarih seçildiğinde rastgele bir çarpanla veriyi güncelle
        _updateDynamicData('Aylık');
      });
    }
  }

  // --- UI YARDIMCILARI ---
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.black.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 10,
          bottom: 40 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          // 1. SABİT BÖLÜM: ŞU ANKİ SÜRÜ DURUMU
          const Text(
            'Güncel Sürü Durumu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
          const SizedBox(height: 15),

          // Büyük Toplam İnek Kartı
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
                      'Toplam Hayvan',
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _currentHerd['Toplam İnek'].toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.pets_rounded,
                  color: AppColors.primaryGreen,
                  size: 50,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Alt Kategoriler Yatay Liste
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCountBadge(
                  'Süt Veren',
                  _currentHerd['Süt Verenler']!,
                  AppColors.primaryGreen,
                ),
                const SizedBox(width: 10),
                _buildCountBadge(
                  'Hamile',
                  _currentHerd['Hamileler']!,
                  AppColors.secondaryPink,
                ),
                const SizedBox(width: 10),
                _buildCountBadge(
                  'Düve',
                  _currentHerd['Düveler']!,
                  AppColors.strawYellow,
                ),
                const SizedBox(width: 10),
                _buildCountBadge(
                  'Dana',
                  _currentHerd['Danalar']!,
                  AppColors.black,
                ),
                const SizedBox(width: 10),
                _buildCountBadge(
                  'Buzağı',
                  _currentHerd['Buzağılar']!,
                  AppColors.barnRed,
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 25),
            child: Divider(color: AppColors.black, thickness: 2),
          ),

          // 2. DİNAMİK BÖLÜM: ZAMAN FİLTRESİ
          const Text(
            'Performans Analizi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _timeFilters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == _timeFilters[index];
                return GestureDetector(
                  onTap: () {
                    if (_timeFilters[index] == 'Tarih Seç') {
                      _pickPremiumDateRange();
                    } else {
                      _updateDynamicData(_timeFilters[index]);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.black : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _timeFilters[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_customDateText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Row(
                children: [
                  const Icon(
                    Icons.date_range_rounded,
                    color: AppColors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Seçilen Aralık: $_customDateText',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 25),

          // 3. ÜRETİM VE TÜKETİM BÖLÜMÜ
          Row(
            children: [
              Container(
                width: 5,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Üretim ve Tüketim',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildStatCard(
            'Üretilen Süt',
            '${_milkProduced.toStringAsFixed(0)} Litre',
            Icons.water_drop_rounded,
            AppColors.primaryGreen,
          ),
          const SizedBox(height: 10),
          _buildStatCard(
            'Kullanılan Yem',
            '${_feedUsed.toStringAsFixed(0)} Kg',
            Icons.inventory_2_rounded,
            AppColors.strawYellow,
          ),
          const SizedBox(height: 10),
          _buildStatCard(
            'Tüketilen Saman',
            '${_strawUsed.toStringAsFixed(0)} Balya',
            Icons.grass_rounded,
            AppColors.barnRed,
          ),
          const SizedBox(height: 10),
          _buildStatCard(
            'Tüketilen Silaj',
            '${_silageUsed.toStringAsFixed(0)} Kg',
            Icons.eco_rounded,
            AppColors.primaryGreen,
          ),

          const SizedBox(height: 35),

          // 4. OLAYLAR BÖLÜMÜ
          Row(
            children: [
              Container(
                width: 5,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Kayıtlı Olaylar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: [
              _buildEventMiniCard(
                'Doğum',
                _birthCount,
                AppColors.secondaryPink,
                Icons.child_care_rounded,
              ),
              _buildEventMiniCard(
                'Hastalık',
                _sickCount,
                AppColors.barnRed,
                Icons.sick_rounded,
              ),
              _buildEventMiniCard(
                'Kesilen',
                _slaughterCount,
                AppColors.black,
                Icons.content_cut_rounded,
              ),
              _buildEventMiniCard(
                'Tedavi',
                _treatmentCount,
                AppColors.primaryGreen,
                Icons.medical_services_rounded,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 5. YILLIK İNEK SAYISI TREND GRAFİĞİ (CustomPaint)
          const Text(
            'Yıllık Sürü Büyüme Trendi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.black, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(27),
              child: CustomPaint(
                painter: HerdGrowthPainter(),
              ), // Altın renkli özel grafik
            ),
          ),

          const SizedBox(height: 35),

          // 6. YILLIK SÜT ÜRETİMİ (BAR GRAFİĞİ - Overflow Korumalı)
          const Text(
            'Aylık Süt Üretimi (Ton)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
          const SizedBox(height: 15),
          Container(
            height: 220,
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.black, width: 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMilkBar('Oca', 0.6),
                _buildMilkBar('Şub', 0.7),
                _buildMilkBar('Mar', 0.8),
                _buildMilkBar('Nis', 0.9),
                _buildMilkBar('May', 0.85),
                _buildMilkBar('Haz', 1.0), // Haziranda en yüksek
              ],
            ),
          ),
          const SizedBox(height: 35),

          // 7. YENİ EKLENEN KISIM: SON İŞLEM GEÇMİŞİ
          const Text(
            'Son Sistem Olayları',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
          const SizedBox(height: 15),

          ..._recentEvents
              .map(
                (event) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.black, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (event['color'] as Color).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          event['icon'] as IconData,
                          color: event['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event['desc'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppColors.black.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DateFormat(
                          'dd MMM\nHH:mm',
                          'tr_TR',
                        ).format(event['date'] as DateTime),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  // Ufak Olay Kartları (Doğum, Hastalık vb.)
  Widget _buildEventMiniCard(
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                bottomLeft: Radius.circular(13),
              ),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Süt Bar Grafiği Sütunu (FractionallySizedBox ile taşma korumalı)
  Widget _buildMilkBar(String month, double percentage) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: percentage,
                child: Container(
                  width: 35,
                  decoration: BoxDecoration(
                    gradient: AppColors.greenGradient,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.black, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            month,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SÜRÜ BÜYÜME GRAFİĞİ RESSAMI (CustomPaint)
// ==========================================
class HerdGrowthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Yıllık büyüme verisi (Oransal: 0 ile 1 arası)
    final data = [0.4, 0.45, 0.5, 0.52, 0.6, 0.7, 0.85];

    final paintLine = Paint()
      ..color = AppColors
          .strawYellow // Altın Sarısı Trend
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final fillPath = Path();

    double stepX = size.width / (data.length - 1);

    path.moveTo(0, size.height - (data[0] * size.height));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (data[0] * size.height));

    for (int i = 0; i < data.length - 1; i++) {
      double x1 = i * stepX;
      double y1 = size.height - (data[i] * size.height);
      double x2 = (i + 1) * stepX;
      double y2 = size.height - (data[i + 1] * size.height);

      double controlPointX = x1 + (x2 - x1) / 2;

      path.cubicTo(controlPointX, y1, controlPointX, y2, x2, y2);
      fillPath.cubicTo(controlPointX, y1, controlPointX, y2, x2, y2);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      colors: [AppColors.strawYellow.withOpacity(0.4), Colors.transparent],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    final paintFill = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    final paintDot = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    for (int i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(i * stepX, size.height - (data[i] * size.height)),
        6,
        paintLine,
      );
      canvas.drawCircle(
        Offset(i * stepX, size.height - (data[i] * size.height)),
        4,
        paintDot,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

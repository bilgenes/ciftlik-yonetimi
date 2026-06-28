import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/settings_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  // Profil Ayarları
  final _nameCtrl = TextEditingController(text: 'Enes');

  // Piyasa Birim Fiyatları
  final _milkPriceCtrl = TextEditingController(text: '15.50');
  final _feedPriceCtrl = TextEditingController(text: '12.00');
  final _strawPriceCtrl = TextEditingController(text: '50.00');
  final _silagePriceCtrl = TextEditingController(text: '4.50');

  // Kategoriler
  final List<String> _categories = [
    'Süt Veren İnekler',
    'Düveler',
    'Hamile İnekler',
    'Danalar',
    'Buzağılar',
  ];
  String _selectedCategory = 'Süt Veren İnekler';

  // Katsayıları tutan harita
  final Map<String, Map<String, TextEditingController>> _categoryCoefficients =
      {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Varsayılan katsayıları başlatıyoruz
    for (var cat in _categories) {
      _categoryCoefficients[cat] = {
        'prodMilk': TextEditingController(
          text: cat == 'Süt Veren İnekler' ? '25' : '0',
        ),
        'consMilk': TextEditingController(text: cat == 'Buzağılar' ? '6' : '0'),
        'feed': TextEditingController(
          text: cat == 'Süt Veren İnekler'
              ? '8'
              : (cat == 'Buzağılar' ? '1' : '5'),
        ),
        'straw': TextEditingController(text: cat == 'Buzağılar' ? '0' : '1'),
        'silage': TextEditingController(text: cat == 'Buzağılar' ? '0' : '15'),
      };
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _milkPriceCtrl.dispose();
    _feedPriceCtrl.dispose();
    _strawPriceCtrl.dispose();
    _silagePriceCtrl.dispose();
    for (var cat in _categories) {
      _categoryCoefficients[cat]?.forEach((key, ctrl) => ctrl.dispose());
    }
    super.dispose();
  }

  InputDecoration _premiumInputDeco(
    String label,
    IconData icon, {
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.black),
      suffixText: suffix,
      suffixStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.black, width: 2.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.black, width: 2.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 3),
      ),
    );
  }

  // Ayarları Paketleyip Provider'a Gönderme İşlemi
  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    // Tüm verileri düz bir JSON objesi (Map) haline getiriyoruz (Örn: 'milk_price': 15.5)
    Map<String, dynamic> dataToSave = {
      'profile_name': _nameCtrl.text,
      'milk_price': _milkPriceCtrl.text,
      'feed_price': _feedPriceCtrl.text,
      'straw_price': _strawPriceCtrl.text,
      'silage_price': _silagePriceCtrl.text,
    };

    // Kategorilerin katsayılarını düzleştirip ekliyoruz (Örn: sut_veren_inekler_feed)
    for (var cat in _categories) {
      String prefix = cat
          .replaceAll(' ', '_')
          .toLowerCase(); // Örn: süt veren inekler -> sut_veren_inekler
      final ctrls = _categoryCoefficients[cat]!;

      dataToSave['${prefix}_prodMilk'] = ctrls['prodMilk']!.text;
      dataToSave['${prefix}_consMilk'] = ctrls['consMilk']!.text;
      dataToSave['${prefix}_feed'] = ctrls['feed']!.text;
      dataToSave['${prefix}_straw'] = ctrls['straw']!.text;
      dataToSave['${prefix}_silage'] = ctrls['silage']!.text;
    }

    final success = await ref
        .read(settingsProvider.notifier)
        .saveSettings(dataToSave);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '🎉 Tüm katsayılar ve çiftlik rasyon motoru başarıyla güncellendi!',
            ),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kayıt başarısız oldu. Sunucu bağlantınızı kontrol edin.',
            ),
            backgroundColor: AppColors.barnRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Backend'den veri geldiğinde controller'ları DOLDURMA İŞLEMİ
    ref.listen<AsyncValue<Map<String, dynamic>>>(settingsProvider, (
      previous,
      next,
    ) {
      if (previous?.value == null &&
          next.value != null &&
          next.value!.isNotEmpty) {
        final data = next.value!;

        _nameCtrl.text = data['profile_name']?.toString() ?? _nameCtrl.text;
        _milkPriceCtrl.text =
            data['milk_price']?.toString() ?? _milkPriceCtrl.text;
        _feedPriceCtrl.text =
            data['feed_price']?.toString() ?? _feedPriceCtrl.text;
        _strawPriceCtrl.text =
            data['straw_price']?.toString() ?? _strawPriceCtrl.text;
        _silagePriceCtrl.text =
            data['silage_price']?.toString() ?? _silagePriceCtrl.text;

        for (var cat in _categories) {
          String prefix = cat.replaceAll(' ', '_').toLowerCase();
          final ctrls = _categoryCoefficients[cat]!;

          ctrls['prodMilk']!.text =
              data['${prefix}_prodMilk']?.toString() ?? ctrls['prodMilk']!.text;
          ctrls['consMilk']!.text =
              data['${prefix}_consMilk']?.toString() ?? ctrls['consMilk']!.text;
          ctrls['feed']!.text =
              data['${prefix}_feed']?.toString() ?? ctrls['feed']!.text;
          ctrls['straw']!.text =
              data['${prefix}_straw']?.toString() ?? ctrls['straw']!.text;
          ctrls['silage']!.text =
              data['${prefix}_silage']?.toString() ?? ctrls['silage']!.text;
        }
      }
    });

    final currentCtrls = _categoryCoefficients[_selectedCategory]!;
    final settingsAsyncValue = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: settingsAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, stack) => Center(child: Text('Ayar yükleme hatası: $err')),
        data: (_) {
          return ListView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 30 + MediaQuery.of(context).padding.bottom,
            ),
            children: [
              // 1. BÖLÜM: PROFİL / İSİM AYARI
              const Text(
                'Hesap Ayarları',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameCtrl,
                  decoration: _premiumInputDeco(
                    'Çiftçi / Yönetici Adı',
                    Icons.person_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // 2. BÖLÜM: BİRİM FİYAT MOTORU
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Piyasa Birim Fiyatları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 2.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _milkPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Süt Satış',
                              Icons.water_drop,
                              suffix: '₺/L',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _feedPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Yem Alış',
                              Icons.shopping_bag,
                              suffix: '₺/Kg',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _strawPriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Saman Alış',
                              Icons.grass,
                              suffix: '₺/Bl',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _silagePriceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Silaj Alış',
                              Icons.eco,
                              suffix: '₺/Kg',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // 3. BÖLÜM: SEKME SEKME KATEGORİ AYARLARI
              const Text(
                'Kategori Oranları',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Comfortaa',
                ),
              ),
              Text(
                'Seçtiğiniz kategorideki tek bir hayvanın günlük rasyon ve üretim katsayıları.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategory == _categories[index];
                    return GestureDetector(
                      onTap: () => setState(
                        () => _selectedCategory = _categories[index],
                      ),
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
                            _categories[index],
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Ortalama $_selectedCategory Girdileri',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const Divider(
                      color: AppColors.black,
                      thickness: 2,
                      height: 25,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: currentCtrls['prodMilk'],
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Günlük Üret. Süt',
                              Icons.add_chart_rounded,
                              suffix: 'L',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: currentCtrls['consMilk'],
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Günlük Tük. Süt',
                              Icons.play_for_work_rounded,
                              suffix: 'L',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: currentCtrls['feed'],
                      keyboardType: TextInputType.number,
                      decoration: _premiumInputDeco(
                        'Günlük Hazır Yem Tüketimi',
                        Icons.inventory_2_rounded,
                        suffix: 'Kg',
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: currentCtrls['straw'],
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Saman Tüketimi',
                              Icons.grass_rounded,
                              suffix: 'Balya',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: currentCtrls['silage'],
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Silaj Tüketimi',
                              Icons.eco_rounded,
                              suffix: 'Kg',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 4. BÖLÜM: AYARLARI GÜNCELLE BUTONU
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
                      ),
                    ),
                    elevation: 6,
                  ),
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.white,
                              size: 26,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'SİSTEM KATSAYILARINI KAYDET',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Comfortaa',
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

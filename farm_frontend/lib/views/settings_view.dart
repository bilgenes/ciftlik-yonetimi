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
  final _nameCtrl = TextEditingController();
  final _milkPriceCtrl = TextEditingController(text: '15.50');
  final _feedPriceCtrl = TextEditingController(text: '12.00');
  final _strawPriceCtrl = TextEditingController(text: '50.00');
  final _silagePriceCtrl = TextEditingController(text: '4.50');

  final List<String> _categories = [
    'Süt Veren İnekler',
    'Düveler',
    'Hamile İnekler',
    'Danalar',
    'Buzağılar',
  ];
  String _selectedCategory = 'Süt Veren İnekler';
  final Map<String, Map<String, TextEditingController>> _categoryCoefficients =
      {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Sadece süt üretimi bırakıldı
    for (var cat in _categories) {
      _categoryCoefficients[cat] = {
        'prodMilk': TextEditingController(
          text: cat == 'Süt Veren İnekler' ? '25' : '0',
        ),
      };
    }
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

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    Map<String, dynamic> dataToSave = {
      'profile_name': _nameCtrl.text,
      'milk_price': _milkPriceCtrl.text,
      'feed_price': _feedPriceCtrl.text,
      'straw_price': _strawPriceCtrl.text,
      'silage_price': _silagePriceCtrl.text,
    };
    for (var cat in _categories) {
      String prefix = cat
          .replaceAll(' ', '_')
          .toLowerCase()
          .replaceAll('ı', 'i')
          .replaceAll('ğ', 'g')
          .replaceAll('ü', 'u')
          .replaceAll('ş', 's')
          .replaceAll('ö', 'o')
          .replaceAll('ç', 'c');
      final ctrls = _categoryCoefficients[cat]!;
      dataToSave['${prefix}_prodMilk'] = ctrls['prodMilk']!.text;
    }

    final success = await ref
        .read(settingsProvider.notifier)
        .saveSettings(dataToSave);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '🎉 Ayarlar başarıyla güncellendi!' : 'Kayıt başarısız!',
          ),
          backgroundColor: success ? AppColors.primaryGreen : AppColors.barnRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          String prefix = cat
              .replaceAll(' ', '_')
              .toLowerCase()
              .replaceAll('ı', 'i')
              .replaceAll('ğ', 'g')
              .replaceAll('ü', 'u')
              .replaceAll('ş', 's')
              .replaceAll('ö', 'o')
              .replaceAll('ç', 'c');
          final ctrls = _categoryCoefficients[cat]!;
          ctrls['prodMilk']!.text =
              data['${prefix}_prodMilk']?.toString() ?? ctrls['prodMilk']!.text;
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
                'Seçilen kategorideki bir hayvanın "Günlük" ortalama süt üretimi.',
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
                    TextField(
                      controller: currentCtrls['prodMilk'],
                      keyboardType: TextInputType.number,
                      decoration: _premiumInputDeco(
                        'Günlük Süt Üretimi',
                        Icons.water_drop_rounded,
                        suffix: 'Litre/Gün',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
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

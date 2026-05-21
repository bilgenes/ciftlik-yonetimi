import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/providers/cow_provider.dart';
import 'package:farm_frontend/widgets/shimmer_loading.dart';
import 'package:farm_frontend/models/cow.dart';

// --- GELİŞMİŞ VERİ MODELİ ---
// (Cow modeli backend'den JSON olarak geleceği için artık toJson/fromJson yapısına ihtiyacımız var.
// Şimdilik dynamic kullanarak veya Map'den dönüştürerek halledebiliriz.)

class CowsView extends ConsumerStatefulWidget {
  const CowsView({super.key});

  @override
  ConsumerState<CowsView> createState() => _CowsViewState();
}

class _CowsViewState extends ConsumerState<CowsView> {
  // 1. Kategoriler Güncellendi
  final List<String> _categories = [
    'Tümü',
    'Süt Veren İnekler',
    'Düveler',
    'Hamile İnekler',
    'Danalar',
    'Buzağılar',
    'Ayrılanlar',
  ];
  String _selectedCategory = 'Tümü';

  List<Cow> _getFilteredCows(List<Cow> cows) {
    if (_selectedCategory == 'Tümü') {
      return cows.where((c) => c.status == 'Aktif').toList();
    }
    if (_selectedCategory == 'Ayrılanlar') {
      return cows.where((c) => c.status != 'Aktif').toList();
    }
    return cows
        .where((c) => c.category == _selectedCategory && c.status == 'Aktif')
        .toList();
  }

  // --- ORTAK EKLEME / DÜZENLEME FORMU ---
  // Ekrana sığmama ve eksik bilgi sorununu çözmek için devasa, kaydırılabilir bir BottomSheet yaptık.
  void _showCowForm({Cow? cowToEdit}) {
    final isEditing = cowToEdit != null;
    final formKey = GlobalKey<FormState>();

    // Controller'lar
    final tagCtrl = TextEditingController(
      text: isEditing ? cowToEdit.tagNumber : '',
    );
    final nameCtrl = TextEditingController(
      text: isEditing ? cowToEdit.name : '',
    );
    final diseaseCtrl = TextEditingController(
      text: isEditing ? cowToEdit.chronicDisease : '',
    );
    final historyCtrl = TextEditingController(
      text: isEditing ? cowToEdit.medicalHistory : '',
    );
    final notesCtrl = TextEditingController(
      text: isEditing ? cowToEdit.notes : '',
    );
    final calfCtrl = TextEditingController(
      text: isEditing ? cowToEdit.calfCount.toString() : '0',
    );
    final milkCtrl = TextEditingController(
      text: isEditing ? cowToEdit.totalMilkProduced.toString() : '0',
    );
    final incomeCtrl = TextEditingController(
      text: isEditing ? cowToEdit.totalIncome.toString() : '0',
    );
    final costCtrl = TextEditingController(
      text: isEditing ? cowToEdit.totalCost.toString() : '0',
    );

    DateTime? selectedDate = isEditing ? cowToEdit.birthDate : null;
    String selectedCat = isEditing ? cowToEdit.category : 'Süt Veren İnekler';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Klavyenin üstüne çıkabilmesi için hayati ayar
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  24, // Klavye boşluğu
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              border: Border(
                top: BorderSide(color: AppColors.black, width: 4),
                left: BorderSide(color: AppColors.black, width: 4),
                right: BorderSide(color: AppColors.black, width: 4),
              ),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? '✏️ Kimliği Düzenle' : '🐮 Yeni Hayvan Kaydı',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Comfortaa',
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Alanları (Kaydırılabilir)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildPremiumTextField(
                            'Küpe Numarası (Zorunlu)',
                            Icons.confirmation_number,
                            tagCtrl,
                            isRequired: true,
                          ),
                          const SizedBox(height: 15),
                          _buildPremiumTextField('İsim', Icons.pets, nameCtrl),
                          const SizedBox(height: 15),

                          // Doğum Tarihi Seçici
                          InkWell(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null)
                                setModalState(() => selectedDate = date);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.black,
                                  width: 2.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.black,
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    selectedDate != null
                                        ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(selectedDate!)
                                        : 'Doğum Tarihi Seç (Zorunlu)',
                                    style: TextStyle(
                                      fontWeight: selectedDate != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: AppColors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          // Kategori Seçici
                          DropdownButtonFormField<String>(
                            value: selectedCat,
                            decoration: _premiumInputDeco(
                              'Durumu / Kategorisi',
                              Icons.category,
                            ),
                            items: _categories
                                .where((c) => c != 'Tümü' && c != 'Ayrılanlar')
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setModalState(() => selectedCat = val!),
                          ),
                          const SizedBox(height: 15),

                          // Sayısal Veriler Yan Yana
                          Row(
                            children: [
                              Expanded(
                                child: _buildPremiumTextField(
                                  'Yavru Sayısı',
                                  Icons.child_care,
                                  calfCtrl,
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildPremiumTextField(
                                  'Top. Süt (L)',
                                  Icons.water_drop,
                                  milkCtrl,
                                  isNumber: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPremiumTextField(
                                  'Kazanç (₺)',
                                  Icons.trending_up,
                                  incomeCtrl,
                                  isNumber: true,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildPremiumTextField(
                                  'Maliyet (₺)',
                                  Icons.trending_down,
                                  costCtrl,
                                  isNumber: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Tıbbi Geçmiş ve Notlar
                          _buildPremiumTextField(
                            'Kalıcı Hastalık',
                            Icons.medical_services,
                            diseaseCtrl,
                          ),
                          const SizedBox(height: 15),
                          _buildPremiumTextField(
                            'İşlem/Hastalık Geçmişi',
                            Icons.history,
                            historyCtrl,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 15),
                          _buildPremiumTextField(
                            'Özel Notlar',
                            Icons.edit_note,
                            notesCtrl,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // Kaydet Butonu (Sabit Alt Kısım)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: AppColors.black,
                            width: 3,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate() &&
                            selectedDate != null) {
                          setState(() {
                            if (isEditing) {
                              // Düzenleme (Gerçekte API'ye PUT atılacak)
                              cowToEdit.tagNumber = tagCtrl.text;
                              cowToEdit.name = nameCtrl.text.isEmpty
                                  ? 'İsimsiz'
                                  : nameCtrl.text;
                              cowToEdit.birthDate = selectedDate!;
                              cowToEdit.category = selectedCat;
                              cowToEdit.calfCount =
                                  int.tryParse(calfCtrl.text) ?? 0;
                              cowToEdit.totalMilkProduced =
                                  double.tryParse(milkCtrl.text) ?? 0.0;
                              cowToEdit.totalIncome =
                                  double.tryParse(incomeCtrl.text) ?? 0.0;
                              cowToEdit.totalCost =
                                  double.tryParse(costCtrl.text) ?? 0.0;
                              cowToEdit.chronicDisease = diseaseCtrl.text;
                              cowToEdit.medicalHistory = historyCtrl.text;
                              cowToEdit.notes = notesCtrl.text;
                            } else {
                              // Yeni Ekleme (Gerçekte API'ye POST atılacak)
                              // _cows listesi kaldırıldığı için burada API çağrısı yapılmalı
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Yeni hayvan ekleme API\'ye bağlanacak.'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                              // İşlem bittikten sonra: ref.refresh(cowProvider);
                            }
                          });
                          Navigator.pop(context); // Formu Kapat
                          if (isEditing)
                            Navigator.pop(
                              context,
                            ); // Detay penceresini de kapat (yenilenmesi için)
                        } else if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Doğum tarihi seçmek zorunludur!'),
                              backgroundColor: AppColors.barnRed,
                            ),
                          );
                        }
                      },
                      child: Text(
                        isEditing ? 'Değişiklikleri Kaydet' : 'İneği Kaydet',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- ALT PENCERE: İNEK DETAYLARI (KİMLİK KARTI) ---
  void _showCowDetails(Cow cow) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        padding: const EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 24,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          border: Border(
            top: BorderSide(color: AppColors.black, width: 4),
            left: BorderSide(color: AppColors.black, width: 4),
            right: BorderSide(color: AppColors.black, width: 4),
          ),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 50,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Başlık ve Düzenle Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${cow.tagNumber} | ${cow.name}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: 'Comfortaa',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit_square,
                    color: AppColors.black,
                    size: 28,
                  ),
                  onPressed: () => _showCowForm(cowToEdit: cow),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Detaylar (Kaydırılabilir Alan)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildDetailCard('Temel Bilgiler', [
                      _buildInfoRow(
                        Icons.cake,
                        'Doğum / Yaş',
                        '${DateFormat('dd/MM/yyyy').format(cow.birthDate)} (${cow.ageString})',
                      ),
                      _buildInfoRow(
                        Icons.category,
                        'Durum',
                        cow.category,
                        color: AppColors.primaryGreen,
                      ),
                      _buildInfoRow(
                        Icons.child_care,
                        'Yavru Sayısı',
                        '${cow.calfCount} Adet',
                      ),
                    ]),
                    const SizedBox(height: 15),

                    _buildDetailCard('Üretim ve Sağlık', [
                      _buildInfoRow(
                        Icons.water_drop,
                        'Top. Üretilen Süt',
                        '${cow.totalMilkProduced} Litre',
                        color: AppColors.black,
                      ),
                      _buildInfoRow(
                        Icons.warning,
                        'Kalıcı Hastalık',
                        cow.chronicDisease,
                        color: cow.chronicDisease == 'Yok'
                            ? AppColors.primaryGreen
                            : AppColors.barnRed,
                      ),
                      _buildInfoRow(
                        Icons.history,
                        'İşlem Geçmişi',
                        cow.medicalHistory,
                      ),
                    ]),
                    const SizedBox(height: 15),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.blackGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.black, width: 3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFinanceItem(
                              'Kazandırdığı',
                              '+₺${cow.totalIncome}',
                              AppColors.primaryGreen,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.white.withOpacity(0.2),
                          ),
                          Expanded(
                            child: _buildFinanceItem(
                              'Maliyeti',
                              '-₺${cow.totalCost}',
                              AppColors.barnRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (cow.notes.isNotEmpty)
                      _buildDetailCard('Notlar', [
                        Text(
                          cow.notes,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Öldü ve Kesildi Butonları (Sabit En Alt)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColors.barnRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: AppColors.black,
                          width: 3,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.dangerous, color: AppColors.white),
                    label: const Text(
                      'Öldü',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      setState(() => cow.status = 'Öldü');
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColors.strawYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: AppColors.black,
                          width: 3,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.content_cut, color: AppColors.black),
                    label: const Text(
                      'Kesildi',
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSlaughterDialog(cow);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Kesim Geliri Pop-up'ı
  void _showSlaughterDialog(Cow cow) {
    final incomeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.black, width: 3),
        ),
        title: const Text(
          '🔪 Kesim İşlemi',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: incomeCtrl,
          keyboardType: TextInputType.number,
          decoration: _premiumInputDeco(
            'Elde Edilen Gelir (₺)',
            Icons.payments,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'İptal',
              style: TextStyle(
                color: AppColors.barnRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: AppColors.black, width: 2),
              ),
            ),
            onPressed: () {
              setState(() {
                cow.status = 'Kesildi';
                cow.totalIncome += double.tryParse(incomeCtrl.text) ?? 0.0;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Onayla',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- YARDIMCI UI WIDGETLARI ---
  Widget _buildPremiumTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isRequired = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: _premiumInputDeco(label, icon),
      validator: isRequired
          ? (val) => val!.isEmpty ? 'Bu alan zorunludur!' : null
          : null,
    );
  }

  InputDecoration _premiumInputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.black),
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

  Widget _buildDetailCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.black, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const Divider(color: AppColors.black, thickness: 2, height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color color = AppColors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.black.withOpacity(0.6)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.black.withOpacity(0.6),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceItem(String title, String amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cowAsyncValue = ref.watch(cowProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCowForm(),
        backgroundColor: AppColors.strawYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.black, width: 3),
        ),
        icon: const Icon(Icons.add, color: AppColors.black),
        label: const Text(
          'İnek Ekle',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          // YENİ: KAMERAYLA KÜPE OKUMA ALANI
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: () {
                // TODO: Kamera barkod paketi buraya bağlanacak
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kamera modülü yakında eklenecek!'),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Kamerayla Küpe Oku',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // YATAY KATEGORİ FİLTRESİ
          Container(
            height: 70,
            padding: const EdgeInsets.only(top: 10, bottom: 10, left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == _categories[index];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = _categories[index]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.black : AppColors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.black, width: 2.5),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // İNEK KARTLARI LİSTESİ
          Expanded(
            child: cowAsyncValue.when(
              data: (cows) {
                final filteredCows = _getFilteredCows(cows);
                if (filteredCows.isEmpty) {
                  return const Center(
                    child: Text(
                      'Bu kategoride kayıtlı hayvan bulunmuyor.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCows.length,
                    itemBuilder: (context, index) {
                      final cow = filteredCows[index];
                      return InkWell(
                        onTap: () => _showCowDetails(cow),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.black,
                              width: 3,
                            ), // Kalın Premium Kontür
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
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.15,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryGreen,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.grass_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cow.tagNumber,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${cow.name} • ${cow.ageString.split(',')[0]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.black.withOpacity(0.6),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryPink.withOpacity(
                                    0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.secondaryPink,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  cow.category,
                                  style: const TextStyle(
                                    color: AppColors.secondaryPink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
              },
              loading: () => const ShimmerLoadingList(),
              error: (err, stack) => Center(child: Text('Hata: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

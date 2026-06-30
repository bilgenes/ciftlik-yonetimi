import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/ui_helper.dart';
import '../providers/cow_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/finance_provider.dart';
import '../widgets/shimmer_loading.dart';
import '../models/cow.dart';

class CowsView extends ConsumerStatefulWidget {
  const CowsView({super.key});

  @override
  ConsumerState<CowsView> createState() => _CowsViewState();
}

class _CowsViewState extends ConsumerState<CowsView> {
  // Ayrılanlar sekmesi tamamen kaldırıldı
  final List<String> _categories = [
    'Tümü',
    'Süt Veren İnekler',
    'Düveler',
    'Hamile İnekler',
    'Danalar',
    'Buzağılar',
  ];
  String _selectedCategory = 'Tümü';

  List<Cow> _getFilteredCows(List<Cow> cows) {
    if (_selectedCategory == 'Tümü') {
      return cows.where((c) => c.status == 'Aktif').toList();
    }
    return cows
        .where((c) => c.category == _selectedCategory && c.status == 'Aktif')
        .toList();
  }

  // --- AKILLI HESAPLAMA MOTORU ---
  // Ayarlardan gelen katsayılar ile ineğin yaşını çarparak gerçek verileri üretir
  Map<String, double> _calculateDynamicStats(
    Cow cow,
    Map<String, dynamic> settings,
  ) {
    String prefix = cow.category.replaceAll(' ', '_').toLowerCase();
    prefix = prefix
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c'); // Türkçe karakter temizliği

    double prodMilk =
        double.tryParse(settings['${prefix}_prodMilk']?.toString() ?? '0') ?? 0;
    double consMilk =
        double.tryParse(settings['${prefix}_consMilk']?.toString() ?? '0') ?? 0;
    double feed =
        double.tryParse(settings['${prefix}_feed']?.toString() ?? '0') ?? 0;
    double straw =
        double.tryParse(settings['${prefix}_straw']?.toString() ?? '0') ?? 0;
    double silage =
        double.tryParse(settings['${prefix}_silage']?.toString() ?? '0') ?? 0;

    double milkPrice =
        double.tryParse(settings['milk_price']?.toString() ?? '0') ?? 0;
    double feedPrice =
        double.tryParse(settings['feed_price']?.toString() ?? '0') ?? 0;
    double strawPrice =
        double.tryParse(settings['straw_price']?.toString() ?? '0') ?? 0;
    double silagePrice =
        double.tryParse(settings['silage_price']?.toString() ?? '0') ?? 0;

    double dailyIncome = prodMilk * milkPrice;
    double dailyCost =
        (consMilk * milkPrice) +
        (feed * feedPrice) +
        (straw * strawPrice) +
        (silage * silagePrice);

    int days = cow.ageInDays > 0 ? cow.ageInDays : 1;

    return {
      'daily_milk': prodMilk,
      'total_milk': prodMilk * days,
      'daily_income': dailyIncome,
      'total_income': dailyIncome * days,
      'daily_cost': dailyCost,
      'total_cost': dailyCost * days,
    };
  }

  // --- ORTAK EKLEME / DÜZENLEME FORMU ---
  void _showCowForm(List<Cow> allCows, {Cow? cowToEdit}) {
    final isEditing = cowToEdit != null;
    final formKey = GlobalKey<FormState>();

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

    DateTime? selectedDate = isEditing ? cowToEdit.birthDate : null;
    String selectedCat = isEditing ? cowToEdit.category : 'Süt Veren İnekler';
    String? selectedMotherId = isEditing ? cowToEdit.motherId : null;

    // Anne olabilecek yetişkin inekleri filtrele
    List<Cow> potentialMothers = allCows
        .where(
          (c) =>
              c.status == 'Aktif' &&
              (c.category == 'Süt Veren İnekler' ||
                  c.category == 'Hamile İnekler' ||
                  c.category == 'Düveler') &&
              c.id != cowToEdit?.id,
        )
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                                .where((c) => c != 'Tümü')
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

                          // YENİ: ANNESİ SEÇİMİ
                          DropdownButtonFormField<String?>(
                            value: selectedMotherId,
                            decoration: _premiumInputDeco(
                              'Annesi (Opsiyonel)',
                              Icons.family_restroom,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text(
                                  'Belirtilmedi',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...potentialMothers.map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    '${c.tagNumber} - ${c.name}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                setModalState(() => selectedMotherId = val),
                          ),
                          const SizedBox(height: 15),

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

                  // Kaydet Butonu
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
                      onPressed: () async {
                        if (formKey.currentState!.validate() &&
                            selectedDate != null) {
                          if (isEditing) {
                            cowToEdit.tagNumber = tagCtrl.text;
                            cowToEdit.name = nameCtrl.text.isEmpty
                                ? 'İsimsiz'
                                : nameCtrl.text;
                            cowToEdit.birthDate = selectedDate!;
                            cowToEdit.category = selectedCat;
                            cowToEdit.motherId = selectedMotherId;
                            cowToEdit.chronicDisease = diseaseCtrl.text;
                            cowToEdit.medicalHistory = historyCtrl.text;
                            cowToEdit.notes = notesCtrl.text;

                            final success = await ref
                                .read(cowProvider.notifier)
                                .updateCow(cowToEdit);
                            if (success && mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bilgiler güncellendi!'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                          } else {
                            final newCow = Cow(
                              id: '',
                              tagNumber: tagCtrl.text,
                              name: nameCtrl.text.isEmpty
                                  ? 'İsimsiz'
                                  : nameCtrl.text,
                              birthDate: selectedDate!,
                              category: selectedCat,
                              motherId: selectedMotherId,
                              chronicDisease: diseaseCtrl.text.isEmpty
                                  ? 'Yok'
                                  : diseaseCtrl.text,
                              medicalHistory: historyCtrl.text.isEmpty
                                  ? 'Temiz'
                                  : historyCtrl.text,
                              notes: notesCtrl.text,
                            );

                            final success = await ref
                                .read(cowProvider.notifier)
                                .addCow(newCow);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Yeni hayvan eklendi!'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            }
                          }
                          if (mounted) {
                            Navigator.pop(context);
                            if (isEditing) Navigator.pop(context);
                          }
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

  // --- İNEK DETAYLARI (AKILLI KİMLİK KARTI) ---
  void _showCowDetails(
    Cow cow,
    Map<String, dynamic> settings,
    List<Cow> allCows,
  ) {
    // Dinamik katsayıları hesapla
    final stats = _calculateDynamicStats(cow, settings);

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
                  onPressed: () => _showCowForm(allCows, cowToEdit: cow),
                ),
              ],
            ),
            const SizedBox(height: 15),

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
                      // YENİ: Annesi Gösterimi
                      if (cow.motherName != null && cow.motherName!.isNotEmpty)
                        _buildInfoRow(
                          Icons.family_restroom,
                          'Annesi',
                          cow.motherName!,
                        ),
                    ]),
                    const SizedBox(height: 15),

                    _buildDetailCard('Üretim ve Sağlık', [
                      _buildInfoRow(
                        Icons.water_drop,
                        'Günlük Üretim',
                        '${stats['daily_milk']?.toStringAsFixed(1)} Litre',
                        color: AppColors.black,
                      ),
                      _buildInfoRow(
                        Icons.functions,
                        'Tahmini Top. Süt',
                        '${stats['total_milk']?.toStringAsFixed(0)} Litre',
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
                              'Tahmini Kazancı',
                              '+₺${stats['total_income']?.toStringAsFixed(0)}',
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
                              'Tahmini Maliyeti',
                              '-₺${stats['total_cost']?.toStringAsFixed(0)}',
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
                    onPressed: () async {
                      cow.status = 'Öldü';
                      await ref.read(cowProvider.notifier).updateCow(cow);
                      if (mounted) Navigator.pop(context);
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
                      _showSlaughterDialog(cow); // FİNANSA YANSIYACAK KISIM
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

  // Kesim Geliri Pop-up'ı (Doğrudan Finance Provider'ı tetikler)
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
            onPressed: () async {
              if (incomeCtrl.text.isNotEmpty) {
                // 1. Finansa Ekle (Backend İneği otomatik olarak 'Ayrıldı' yapar)
                final success = await ref
                    .read(financeProvider.notifier)
                    .slaughterCow(
                      cowId: cow.id.toString(),
                      tagNumber: cow.tagNumber,
                      price: double.tryParse(incomeCtrl.text) ?? 0,
                    );

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ref.invalidate(cowProvider); // UI inek listesini yenile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hayvan Ayrıldı, gelir Finansa işlendi!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                }
              }
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
    final settingsAsyncValue = ref.watch(
      settingsProvider,
    ); // Ayarları dinliyoruz

    Map<String, dynamic> settings = {};
    if (settingsAsyncValue is AsyncData && settingsAsyncValue.value != null) {
      settings = settingsAsyncValue.value!;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => cowAsyncValue.whenData((cows) => _showCowForm(cows)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: () {
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
                      onTap: () => _showCowDetails(cow, settings, cows),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
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
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.15),
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
                                color: AppColors.secondaryPink.withOpacity(0.2),
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

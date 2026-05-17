import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../core/ui_helper.dart';

// --- GELİŞMİŞ SAĞLIK VERİ MODELLERİ ---
class TreatmentRecord {
  String name;
  DateTime date;
  double cost;
  TreatmentRecord({required this.name, required this.date, required this.cost});
}

class HealthCow {
  String id;
  String tagNumber;
  String name;
  String mainCategory;
  String healthStatus;

  String? diseaseName;
  DateTime? sickSince;

  DateTime? pregnancyStartDate;
  String? motherTag;

  List<TreatmentRecord> treatments;

  HealthCow({
    required this.id,
    required this.tagNumber,
    required this.name,
    required this.mainCategory,
    required this.healthStatus,
    this.diseaseName,
    this.sickSince,
    this.pregnancyStartDate,
    this.motherTag,
    required this.treatments,
  });

  String getDurationString(DateTime? start) {
    if (start == null) return 'Bilinmiyor';
    final now = DateTime.now();
    int months = now.month - start.month + (12 * (now.year - start.year));
    int days = now.day - start.day;
    if (days < 0) {
      months--;
      days += 30;
    }
    return '$months Ay, $days Gün';
  }

  double get totalTreatmentCost {
    return treatments.fold(0, (sum, item) => sum + item.cost);
  }
}

class HealthView extends StatefulWidget {
  const HealthView({super.key});

  @override
  State<HealthView> createState() => _HealthViewState();
}

class _HealthViewState extends State<HealthView> {
  final List<String> _categories = [
    'Hasta Olan Hayvanlar',
    'Hamile İnekler',
    'Buzağılar',
    'Tümü',
    'Danalar',
    'Düveler',
  ];
  String _selectedCategory = 'Hasta Olan Hayvanlar';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  // --- MOCK / SAHTE VERİLER ---
  final List<HealthCow> _animals = [
    HealthCow(
      id: '1',
      tagNumber: 'TR-1122',
      name: 'Sarıkız',
      mainCategory: 'Süt Veren İnekler',
      healthStatus: 'Hasta',
      diseaseName: 'Mastit (Meme İltihabı)',
      sickSince: DateTime.now().subtract(const Duration(days: 5)),
      treatments: [
        TreatmentRecord(
          name: 'Antibiyotik Aşısı',
          date: DateTime.now().subtract(const Duration(days: 4)),
          cost: 850.0,
        ),
        TreatmentRecord(
          name: 'Meme İçi Krem Tedavisi',
          date: DateTime.now().subtract(const Duration(days: 2)),
          cost: 400.0,
        ),
      ],
    ),
    HealthCow(
      id: '2',
      tagNumber: 'TR-3344',
      name: 'Benekli',
      mainCategory: 'Süt Veren İnekler',
      healthStatus: 'Hamile',
      pregnancyStartDate: DateTime.now().subtract(const Duration(days: 145)),
      treatments: [
        TreatmentRecord(
          name: 'A Vitamini Takviyesi',
          date: DateTime.now().subtract(const Duration(days: 90)),
          cost: 350.0,
        ),
        TreatmentRecord(
          name: 'Kuru Dönem Aşısı',
          date: DateTime.now().subtract(const Duration(days: 10)),
          cost: 600.0,
        ),
      ],
    ),
    HealthCow(
      id: '3',
      tagNumber: 'TR-5566',
      name: 'Minik',
      mainCategory: 'Buzağılar',
      healthStatus: 'Sağlıklı',
      motherTag: 'TR-3344',
      treatments: [
        TreatmentRecord(
          name: 'Septisemi Aşısı',
          date: DateTime.now().subtract(const Duration(days: 20)),
          cost: 500.0,
        ),
      ],
    ),
  ];

  List<HealthCow> get _filteredAnimals {
    return _animals.where((animal) {
      final matchesSearch =
          animal.tagNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          animal.name.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

      if (_selectedCategory == 'Tümü') return true;
      if (_selectedCategory == 'Hasta Olan Hayvanlar')
        return animal.healthStatus == 'Hasta';
      if (_selectedCategory == 'Hamile İnekler')
        return animal.healthStatus == 'Hamile';
      if (_selectedCategory == 'Buzağılar')
        return animal.mainCategory == 'Buzağılar';
      if (_selectedCategory == 'Danalar')
        return animal.mainCategory == 'Danalar';
      if (_selectedCategory == 'Düveler')
        return animal.mainCategory == 'Düveler';
      return true;
    }).toList();
  }

  // --- HASTALIK FORMU ---
  void _showDiseaseForm(HealthCow animal, StateSetter? parentModalState) {
    final diseaseCtrl = TextEditingController(text: animal.diseaseName ?? '');
    DateTime selectedDate = animal.sickSince ?? DateTime.now();

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setFormState) {
          return Container(
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              // KESİN ÇÖZÜM: Klavye yüksekliği + Telefon alt menü yüksekliği
              bottom:
                  24 +
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    animal.healthStatus == 'Hasta'
                        ? '✏️ Teşhisi Düzenle'
                        : '🩺 Yeni Hastalık Bildir',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Comfortaa',
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: diseaseCtrl,
                    decoration: _premiumInputDeco(
                      'Hastalık Adı / Teşhis',
                      Icons.healing_rounded,
                    ),
                  ),
                  const SizedBox(height: 15),

                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setFormState(() => selectedDate = date);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.black, width: 2.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            'Başlangıç: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.barnRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: AppColors.black,
                            width: 3,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (diseaseCtrl.text.isNotEmpty) {
                          setState(() {
                            animal.healthStatus = 'Hasta';
                            animal.diseaseName = diseaseCtrl.text;
                            animal.sickSince = selectedDate;
                          });
                          if (parentModalState != null) parentModalState(() {});
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
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

  // --- TEDAVİ FORMU ---
  void _showTreatmentForm(HealthCow animal, StateSetter setModalState) {
    final nameCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          // KESİN ÇÖZÜM: Klavye + Alt Menü
          bottom:
              24 +
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                '💉 Tedavi veya Aşı İşle',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: _premiumInputDeco(
                  'Tedavi / İlaç / Aşı Adı',
                  Icons.science_rounded,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: _premiumInputDeco(
                  'Tedavi Maliyeti (₺)',
                  Icons.payments_rounded,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.black, width: 3),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && costCtrl.text.isNotEmpty) {
                      setState(() {
                        animal.treatments.add(
                          TreatmentRecord(
                            name: nameCtrl.text,
                            date: DateTime.now(),
                            cost: double.tryParse(costCtrl.text) ?? 0.0,
                          ),
                        );
                      });
                      setModalState(() {});
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Maliyeti İşle',
                    style: TextStyle(
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
      ),
    );
  }

  // --- DOĞUM FORMU ---
  void _showBirthForm(HealthCow animal) {
    final countCtrl = TextEditingController(text: '1');
    UiHelper.showPremiumBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom:
              24 +
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).padding.bottom,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                '🎉 Doğum Kaydı',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${animal.name} adlı inek için doğan yavru sayısını giriniz:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: countCtrl,
                keyboardType: TextInputType.number,
                decoration: _premiumInputDeco(
                  'Doğan Yavru Sayısı',
                  Icons.numbers_rounded,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strawYellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.black, width: 3),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      animal.healthStatus = 'Sağlıklı';
                      int count = int.tryParse(countCtrl.text) ?? 1;
                      for (int i = 1; i <= count; i++) {
                        _animals.add(
                          HealthCow(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString() +
                                i.toString(),
                            tagNumber: 'TR-YENI$i',
                            name: '${animal.name} Yavrusu $i',
                            mainCategory: 'Buzağılar',
                            healthStatus: 'Sağlıklı',
                            motherTag: animal.tagNumber,
                            treatments: [],
                          ),
                        );
                      }
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🍼 Buzağılar başarıyla kreşe eklendi!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  },
                  child: const Text(
                    'Doğumu Onayla',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DETAY KİMLİK KARTLARI ---
  void _showAnimalHealthDetails(HealthCow animal) {
    // Annesinin İsmini Bulma Mantığı
    String motherName = 'Bilinmiyor';
    if (animal.motherTag != null) {
      try {
        final mother = _animals.firstWhere(
          (c) => c.tagNumber == animal.motherTag,
        );
        motherName = mother.name;
      } catch (e) {
        // Liste dışı bir anneyse 'Bilinmiyor' kalır
      }
    }

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.90,
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              // KESİN ÇÖZÜM: Alt Menü yüksekliğini güvenli boşluğa ekler
              bottom: 24 + MediaQuery.of(context).padding.bottom,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        '${animal.tagNumber} | ${animal.name}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Comfortaa',
                        ),
                      ),
                    ),
                    _buildStatusBadge(animal.healthStatus),
                  ],
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (animal.healthStatus == 'Hasta')
                          _buildPremiumDetailCard(
                            'Mevcut Hastalık Durumu',
                            AppColors.redGradient,
                            [
                              _buildDetailRow(
                                Icons.sick,
                                'Teşhis',
                                animal.diseaseName ?? '',
                              ),
                              _buildDetailRow(
                                Icons.timer,
                                'Hastalık Süresi',
                                animal.getDurationString(animal.sickSince),
                              ),
                              _buildDetailRow(
                                Icons.calendar_month,
                                'Başlangıç',
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(animal.sickSince!),
                              ),
                            ],
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.edit_square,
                                color: AppColors.white,
                              ),
                              onPressed: () =>
                                  _showDiseaseForm(animal, setModalState),
                            ),
                          ),

                        if (animal.healthStatus == 'Hamile')
                          _buildPremiumDetailCard(
                            'Gebelik ve Takip Kartı',
                            AppColors.greenGradient,
                            [
                              _buildDetailRow(
                                Icons.calendar_month,
                                'Başlangıç',
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(animal.pregnancyStartDate!),
                              ),
                              _buildDetailRow(
                                Icons.hourglass_empty,
                                'Gebelik Süresi',
                                animal.getDurationString(
                                  animal.pregnancyStartDate,
                                ),
                              ),
                            ],
                          ),

                        if (animal.mainCategory == 'Buzağılar')
                          _buildPremiumDetailCard(
                            'Soy ve Büyüme Kartı',
                            AppColors.blackGradient,
                            [
                              // ANNESİNİN İSMİ BURAYA EKLENDİ
                              _buildDetailRow(
                                Icons.female,
                                'Anne Bilgisi',
                                '${animal.motherTag ?? 'Bilinmiyor'} - $motherName',
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),
                        _buildSectionHeader(
                          'Uygulanan Aşılar ve Tedavi Geçmişi',
                        ),
                        const SizedBox(height: 10),
                        if (animal.treatments.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.black,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Henüz bir tedavi veya aşı kaydı girilmemiş.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          ...animal.treatments
                              .map(
                                (t) => Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat(
                                              'dd/MM/yyyy - HH:mm',
                                            ).format(t.date),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₺${t.cost.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppColors.barnRed,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),

                        const SizedBox(height: 25),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.black,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Toplam Sağlık Maliyeti:',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '₺${animal.totalTreatmentCost.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.strawYellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // --- ALT AKSİYON BUTONLARI (TAMAMEN YENİLENDİ) ---
                Column(
                  children: [
                    // 1. SATIR: TAM GENİŞLİKTE ANA DURUM BUTONU
                    if (animal.healthStatus == 'Sağlıklı')
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          Icons.sick_rounded,
                          'Hastalık Bildir',
                          AppColors.barnRed,
                          AppColors.white,
                          () => _showDiseaseForm(animal, setModalState),
                        ),
                      ),
                    if (animal.healthStatus == 'Hasta')
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          Icons.check_circle_rounded,
                          'İyileşti Olarak İşaretle',
                          AppColors.primaryGreen,
                          AppColors.white,
                          () {
                            setState(() {
                              animal.healthStatus = 'Sağlıklı';
                              animal.diseaseName = null;
                              animal.sickSince = null;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    if (animal.healthStatus == 'Hamile')
                      SizedBox(
                        width: double.infinity,
                        child: _buildActionButton(
                          Icons.child_care_rounded,
                          'Doğum Yaptı',
                          AppColors.strawYellow,
                          AppColors.black,
                          () {
                            Navigator.pop(context);
                            _showBirthForm(animal);
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // 2. SATIR: İKİNCİL İŞLEMLER (Tedavi Gir ve Düve Oldu)
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            Icons.add_moderator_rounded,
                            'Tedavi Gir',
                            AppColors.white,
                            AppColors.black,
                            () => _showTreatmentForm(animal, setModalState),
                          ),
                        ),
                        if (animal.mainCategory == 'Buzağılar') ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              Icons.trending_up_rounded,
                              'Düve Oldu',
                              AppColors.primaryGreen,
                              AppColors.white,
                              () {
                                setState(() {
                                  animal.mainCategory = 'Düveler';
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '🎉 ${animal.name} başarıyla Düve kategorisine aktarıldı!',
                                    ),
                                    backgroundColor: AppColors.primaryGreen,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Ortak Buton Widget'ı
  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.black, width: 2.5),
        ),
      ),
      icon: Icon(icon, color: textColor),
      label: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      onPressed: onTap,
    );
  }

  // --- UI WIDGETLARI ---
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

  Widget _buildPremiumDetailCard(
    String title,
    LinearGradient gradient,
    List<Widget> rows, {
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(color: AppColors.white, thickness: 1.5, height: 20),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white.withOpacity(0.8), size: 20),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Row(
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
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.primaryGreen;
    if (status == 'Hasta') bg = AppColors.barnRed;
    if (status == 'Hamile') bg = AppColors.secondaryPink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kamera tarayıcı aktif ediliyor...'),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.greenGradient,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Kamerayla Küpe / Barkod Oku',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              height: 55,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Küpe No veya İsim ile ara...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.black,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.black,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Container(
            height: 65,
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == _categories[index];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = _categories[index]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.black : AppColors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.black,
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

          Expanded(
            child: _filteredAnimals.isEmpty
                ? const Center(
                    child: Text(
                      'Aradığınız kriterde bir hayvan kaydı bulunamadı.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredAnimals.length,
                    itemBuilder: (context, index) {
                      final animal = _filteredAnimals[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.black,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: InkWell(
                            onTap: animal.healthStatus == 'Sağlıklı'
                                ? () => _showDiseaseForm(animal, null)
                                : null,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: animal.healthStatus == 'Hasta'
                                    ? AppColors.barnRed.withOpacity(0.15)
                                    : (animal.healthStatus == 'Hamile'
                                          ? AppColors.secondaryPink.withOpacity(
                                              0.15,
                                            )
                                          : AppColors.primaryGreen.withOpacity(
                                              0.15,
                                            )),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.black,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                animal.healthStatus == 'Hasta'
                                    ? Icons.sick_rounded
                                    : (animal.healthStatus == 'Hamile'
                                          ? Icons.calendar_today_rounded
                                          : Icons.health_and_safety_rounded),
                                color: animal.healthStatus == 'Hasta'
                                    ? AppColors.barnRed
                                    : (animal.healthStatus == 'Hamile'
                                          ? AppColors.secondaryPink
                                          : AppColors.primaryGreen),
                              ),
                            ),
                          ),
                          title: Text(
                            animal.tagNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          subtitle: Text(
                            '${animal.name} • ${animal.mainCategory}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black.withOpacity(0.5),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStatusBadge(animal.healthStatus),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                          onTap: () => _showAnimalHealthDetails(animal),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

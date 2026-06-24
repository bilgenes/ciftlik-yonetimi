import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/ui_helper.dart';
import '../providers/finance_provider.dart';

class FinanceView extends ConsumerStatefulWidget {
  const FinanceView({super.key});

  @override
  ConsumerState<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends ConsumerState<FinanceView> {
  int _currentTab = 0;

  final List<String> _timeFilters = [
    'Günlük',
    'Haftalık',
    'Aylık',
    'Yıllık',
    'Tarih Seç',
  ];
  String _selectedFilter = 'Aylık';
  String _customDateText = '';

  // Dinamik Hesaplama Fonksiyonları
  double _getTotalIncome(List<FinancialTransaction> transactions) =>
      transactions
          .where((t) => t.type == 'Gelir')
          .fold(0, (sum, t) => sum + t.amount);

  double _getTotalExpense(List<FinancialTransaction> transactions) =>
      transactions
          .where((t) => t.type == 'Gider')
          .fold(0, (sum, t) => sum + t.amount);

  // --- POPUP FORMLAR (API'YE BAĞLANDI) ---
  void _showManualTransactionForm({required bool isIncome}) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String category = isIncome ? 'Diğer Gelir' : 'Diğer Gider';

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
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
                isIncome ? '💵 Manuel Gelir Ekle' : '💸 Manuel Gider Ekle',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: titleCtrl,
                decoration: _premiumInputDeco(
                  'İşlem Açıklaması',
                  Icons.edit_note_rounded,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: _premiumInputDeco(
                  'Tutar (₺)',
                  Icons.payments_rounded,
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncome
                        ? AppColors.primaryGreen
                        : AppColors.barnRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.black, width: 3),
                    ),
                  ),
                  onPressed: () async {
                    if (titleCtrl.text.isNotEmpty &&
                        amountCtrl.text.isNotEmpty) {
                      final success = await ref
                          .read(financeProvider.notifier)
                          .addTransaction(
                            type: isIncome ? 'gelir' : 'gider',
                            category: category,
                            amount: double.tryParse(amountCtrl.text) ?? 0,
                            description: titleCtrl.text,
                          );

                      if (mounted && success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('İşlem kaydedildi.'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'İşlemi Kaydet',
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

  void _showMilkSaleForm() {
    final amountCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
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
                '🥛 Süt Satışı',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: _premiumInputDeco(
                  'Satılan Miktar (Litre)',
                  Icons.water_drop_rounded,
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: _premiumInputDeco(
                  'Toplam Ücret (₺)',
                  Icons.payments_rounded,
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
                  onPressed: () async {
                    if (amountCtrl.text.isNotEmpty &&
                        priceCtrl.text.isNotEmpty) {
                      final success = await ref
                          .read(financeProvider.notifier)
                          .addTransaction(
                            type: 'gelir',
                            category: 'Süt Satışı',
                            amount: double.tryParse(priceCtrl.text) ?? 0,
                            description: '${amountCtrl.text} Litre Süt Satışı',
                          );

                      if (mounted && success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Satış kaydedildi.'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Satışı Onayla',
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

  void _showSlaughterSaleForm() {
    final priceCtrl = TextEditingController();
    // Geliştirme notu: İleride bu listeyi cowProvider üzerinden canlı ineklerle de doldurabilirsin.
    String selectedCow = 'TR-9988 Benekli';

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
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
                '🔪 İnek Kesim Geliri',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comfortaa',
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCow,
                decoration: _premiumInputDeco('Kesilen Hayvan', Icons.pets),
                items: ['TR-9988 Benekli', 'TR-1122 Sarıkız']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => selectedCow = val!,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: _premiumInputDeco(
                  'Elde Edilen Gelir (₺)',
                  Icons.monetization_on_rounded,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(
                        color: AppColors.primaryGreen,
                        width: 3,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (priceCtrl.text.isNotEmpty) {
                      final success = await ref
                          .read(financeProvider.notifier)
                          .addTransaction(
                            type: 'gelir',
                            category: 'Hayvan Kesimi',
                            amount: double.tryParse(priceCtrl.text) ?? 0,
                            description: '$selectedCow Kesimi',
                          );

                      if (mounted && success) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kesim geliri kaydedildi.'),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Geliri Kaydet',
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
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.white,
              surface: AppColors.background,
              onSurface: AppColors.black,
            ),
            dialogBackgroundColor: AppColors.background,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.black,
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
      });
    }
  }

  // --- UI YARDIMCILARI ---
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

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.black, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.black, width: 2.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _currentTab == 0
                      ? AppColors.black
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  'İşlemler',
                  style: TextStyle(
                    color: _currentTab == 0 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Comfortaa',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _currentTab == 1
                      ? AppColors.black
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Finans Analiz',
                  style: TextStyle(
                    color: _currentTab == 1 ? AppColors.white : AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Comfortaa',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tüm verileri Riverpod ile dinliyoruz
    final financeAsyncValue = ref.watch(financeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: financeAsyncValue.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
              error: (err, stack) =>
                  Center(child: Text('Bir hata oluştu: $err')),
              data: (transactions) {
                return _currentTab == 0
                    ? _buildOperationsTab(transactions)
                    : _buildAnalysisTab(transactions);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsTab(List<FinancialTransaction> transactions) {
    return ListView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        const Text(
          'Hızlı İşlemler',
          style: TextStyle(
            fontSize: 22,
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
          childAspectRatio: 1.3,
          children: [
            _buildActionCard(
              'Manuel Gelir',
              Icons.add_circle_outline,
              AppColors.primaryGreen,
              () => _showManualTransactionForm(isIncome: true),
            ),
            _buildActionCard(
              'Manuel Gider',
              Icons.remove_circle_outline,
              AppColors.barnRed,
              () => _showManualTransactionForm(isIncome: false),
            ),
            _buildActionCard(
              'Süt Satımı',
              Icons.water_drop_rounded,
              AppColors.strawYellow,
              _showMilkSaleForm,
            ),
            _buildActionCard(
              'İnek Kesimi',
              Icons.content_cut_rounded,
              AppColors.black,
              _showSlaughterSaleForm,
            ),
          ],
        ),

        const SizedBox(height: 35),
        Row(
          children: [
            Container(
              width: 6,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.black,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Son Finansal İşlemler',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                fontFamily: 'Comfortaa',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'Henüz kaydedilmiş bir finans işlemi bulunmuyor.',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ...transactions
            .map(
              (t) => Container(
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
                        color: t.type == 'Gelir'
                            ? AppColors.primaryGreen.withOpacity(0.15)
                            : AppColors.barnRed.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        t.type == 'Gelir'
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: t.type == 'Gelir'
                            ? AppColors.primaryGreen
                            : AppColors.barnRed,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${t.category} • ${DateFormat('dd MMM yyyy', 'tr_TR').format(t.date)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppColors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${t.type == 'Gelir' ? '+' : '-'}₺${t.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: t.type == 'Gelir'
                            ? AppColors.primaryGreen
                            : AppColors.barnRed,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildAnalysisTab(List<FinancialTransaction> transactions) {
    double totalIncome = _getTotalIncome(transactions);
    double totalExpense = _getTotalExpense(transactions);
    double netProfit = totalIncome - totalExpense;

    return ListView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
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
                    setState(() {
                      _selectedFilter = _timeFilters[index];
                      _customDateText = '';
                    });
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

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.blackGradient,
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
          child: Column(
            children: [
              const Text(
                'NET KAR / ZARAR',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${netProfit >= 0 ? '+' : ''}₺${netProfit.toStringAsFixed(0)}',
                style: TextStyle(
                  color: netProfit >= 0
                      ? AppColors.primaryGreen
                      : AppColors.barnRed,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 2.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Toplam Gelir',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₺${totalIncome.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.black, width: 2.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.barnRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: AppColors.barnRed,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Toplam Gider',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₺${totalExpense.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 35),

        const Text(
          'Gelir & Gider Karşılaştırması',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontFamily: 'Comfortaa',
          ),
        ),
        const SizedBox(height: 15),

        Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.black, width: 3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₺${totalIncome.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: totalIncome == 0
                              ? 0
                              : (totalIncome >= totalExpense
                                    ? 1.0
                                    : (totalIncome / totalExpense)),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: AppColors.greenGradient,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.black,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'GELİR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: double.infinity,
                color: AppColors.black,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '₺${totalExpense.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.barnRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: totalExpense == 0
                              ? 0
                              : (totalExpense >= totalIncome
                                    ? 1.0
                                    : (totalExpense / totalIncome)),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              gradient: AppColors.redGradient,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.black,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'GİDER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 35),
        const Text(
          'Aylık Kar Trendi (Örnek Görsel)',
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
            child: CustomPaint(painter: TrendLinePainter()),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

// Görsel trend tablosu aynı kaldı
class TrendLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final data = [0.3, 0.5, 0.4, 0.7, 0.6, 0.9];
    final paintLine = Paint()
      ..color = AppColors.primaryGreen
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
      colors: [AppColors.primaryGreen.withOpacity(0.5), Colors.transparent],
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

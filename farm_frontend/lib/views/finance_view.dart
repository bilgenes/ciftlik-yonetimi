import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../core/ui_helper.dart';
import '../providers/finance_provider.dart';
import '../providers/cow_provider.dart';
import '../providers/stock_provider.dart';
import '../models/cow.dart';

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
  DateTimeRange? _pickedDateRange;

  // --- ZAMAN FİLTRESİ MOTORU ---
  List<FinancialTransaction> _getFilteredTransactions(
    List<FinancialTransaction> txs,
  ) {
    final now = DateTime.now();
    return txs.where((t) {
      if (_selectedFilter == 'Günlük') {
        return t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day;
      } else if (_selectedFilter == 'Haftalık') {
        return now.difference(t.date).inDays <= 7;
      } else if (_selectedFilter == 'Aylık') {
        return now.difference(t.date).inDays <= 30;
      } else if (_selectedFilter == 'Yıllık') {
        return now.difference(t.date).inDays <= 365;
      } else if (_selectedFilter == 'Tarih Seç' && _pickedDateRange != null) {
        return t.date.isAfter(
              _pickedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            t.date.isBefore(_pickedDateRange!.end.add(const Duration(days: 1)));
      }
      return true; // Varsayılan olarak tümünü göster
    }).toList();
  }

  double _getTotalIncome(List<FinancialTransaction> txs) =>
      txs.where((t) => t.type == 'Gelir').fold(0, (sum, t) => sum + t.amount);
  double _getTotalExpense(List<FinancialTransaction> txs) =>
      txs.where((t) => t.type == 'Gider').fold(0, (sum, t) => sum + t.amount);

  // --- YENİ: 6 AYLIK GELİR/GİDER ÇİZGİ GRAFİĞİ VERİSİ ---
  Map<String, List<double>> _getMonthlyChartData(
    List<FinancialTransaction> txs,
  ) {
    if (txs.isEmpty)
      return {
        'income': [0, 0, 0, 0, 0, 0],
        'expense': [0, 0, 0, 0, 0, 0],
      };

    List<double> incomes = List.filled(6, 0.0);
    List<double> expenses = List.filled(6, 0.0);
    DateTime now = DateTime.now();

    for (var t in txs) {
      int monthDiff = (now.year - t.date.year) * 12 + now.month - t.date.month;
      if (monthDiff >= 0 && monthDiff < 6) {
        if (t.type == 'Gelir') {
          incomes[5 - monthDiff] += t.amount;
        } else {
          expenses[5 - monthDiff] += t.amount;
        }
      }
    }

    // Değerleri 0 ile 1 arasına orantıla (Grafiğe sığması için)
    double maxVal = [...incomes, ...expenses].reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0)
      return {
        'income': [0, 0, 0, 0, 0, 0],
        'expense': [0, 0, 0, 0, 0, 0],
      };

    return {
      'income': incomes.map((v) => v / maxVal).toList(),
      'expense': expenses.map((v) => v / maxVal).toList(),
    };
  }

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
                      if (mounted && success) Navigator.pop(context);
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
                  'Toplam Kazanç (₺)',
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
                          .sellMilk(
                            liters: double.tryParse(amountCtrl.text) ?? 0,
                            price: double.tryParse(priceCtrl.text) ?? 0,
                          );
                      if (mounted && success) {
                        ref.invalidate(stockProvider);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Satış kaydedildi, stoktan düşüldü!'),
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

  void _showSlaughterSaleForm(List<Cow> activeCows) {
    if (activeCows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistemde aktif inek bulunamadı.'),
          backgroundColor: AppColors.barnRed,
        ),
      );
      return;
    }

    final priceCtrl = TextEditingController();
    Cow selectedCow = activeCows.first;

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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

                  DropdownButtonFormField<Cow>(
                    value: selectedCow,
                    decoration: _premiumInputDeco(
                      'Kesilecek Hayvan',
                      Icons.pets,
                    ),
                    items: activeCows
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(
                              '${c.tagNumber} ${c.name ?? ''}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setModalState(() => selectedCow = val!),
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
                              .slaughterCow(
                                cowId: selectedCow.id.toString(),
                                tagNumber: selectedCow.tagNumber,
                                price: double.tryParse(priceCtrl.text) ?? 0,
                              );
                          if (mounted && success) {
                            ref.invalidate(cowProvider);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hayvan Ayrıldı, gelir işlendi!'),
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
          );
        },
      ),
    );
  }

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
        _pickedDateRange = picked;
        _customDateText =
            '${DateFormat('dd MMM').format(picked.start)} - ${DateFormat('dd MMM yyyy').format(picked.end)}';
      });
    }
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
    final financeAsync = ref.watch(financeProvider);
    final cowAsync = ref.watch(cowProvider);

    List<Cow> activeCows = [];
    cowAsync.whenData(
      (cows) => activeCows = cows.where((c) => c.status == 'Aktif').toList(),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildCustomTabBar(),
          Expanded(
            child: financeAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              ),
              error: (err, stack) => Center(child: Text('Hata: $err')),
              data: (transactions) {
                return _currentTab == 0
                    ? _buildOperationsTab(transactions, activeCows)
                    : _buildAnalysisTab(transactions);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsTab(
    List<FinancialTransaction> transactions,
    List<Cow> activeCows,
  ) {
    List<FinancialTransaction> recentTxs = transactions.length > 5
        ? transactions.sublist(0, 5)
        : transactions;

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
              () => _showSlaughterSaleForm(activeCows),
            ),
          ],
        ),

        const SizedBox(height: 35),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                  'Son İşlemler',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: 'Comfortaa',
                  ),
                ),
              ],
            ),
            if (transactions.isNotEmpty)
              TextButton(
                onPressed: () => _openAllTransactionsPage(transactions),
                child: const Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),

        if (recentTxs.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Henüz kaydedilmiş işlem yok.',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        ...recentTxs.map((t) => _buildTransactionCard(t)).toList(),
      ],
    );
  }

  Widget _buildTransactionCard(FinancialTransaction t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.black, width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2)),
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
                  '${t.category} • ${DateFormat('HH:mm', 'tr_TR').format(t.date)}',
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
    );
  }

  void _openAllTransactionsPage(List<FinancialTransaction> txs) {
    Map<String, List<FinancialTransaction>> grouped = {};
    for (var t in txs) {
      String dateKey = DateFormat('dd MMMM yyyy', 'tr_TR').format(t.date);
      if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
      grouped[dateKey]!.add(t);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Tüm Finans Geçmişi',
                style: TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Comfortaa',
                ),
              ),
            ),
            body: ListView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
              ),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    ...entry.value
                        .map((t) => _buildTransactionCard(t))
                        .toList(),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnalysisTab(List<FinancialTransaction> allTransactions) {
    // FİLTRELEME İŞLEMİ
    final filteredTransactions = _getFilteredTransactions(allTransactions);

    double totalIn = _getTotalIncome(filteredTransactions);
    double totalOut = _getTotalExpense(filteredTransactions);
    double netProfit = totalIn - totalOut;

    // GRAFİK VERİSİ (Her zaman tüm işlemlere göre son 6 ayı baz alır)
    final chartData = _getMonthlyChartData(allTransactions);

    return ListView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        // ZAMAN FİLTRELERİ EKLENDİ
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
                      '₺${totalIn.toStringAsFixed(0)}',
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
                      '₺${totalOut.toStringAsFixed(0)}',
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
          'Aylık Gelir-Gider Çizgisi (Son 6 Ay)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            fontFamily: 'Comfortaa',
          ),
        ),
        const SizedBox(height: 15),

        // YENİ: ÇİZGİ GRAFİĞİ
        Container(
          height: 250,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
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
          child: CustomPaint(
            painter: IncomeExpenseLinePainter(
              chartData['income']!,
              chartData['expense']!,
            ),
          ),
        ),

        // Grafik Lejantı
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Gelir',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 20),
              Container(
                width: 15,
                height: 15,
                decoration: const BoxDecoration(
                  color: AppColors.barnRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'Gider',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}

// YEPYENİ GELİR/GİDER ÇİZGİ GRAFİĞİ RESSAMI
class IncomeExpenseLinePainter extends CustomPainter {
  final List<double> incomeData;
  final List<double> expenseData;
  IncomeExpenseLinePainter(this.incomeData, this.expenseData);

  @override
  void paint(Canvas canvas, Size size) {
    if (incomeData.isEmpty || expenseData.isEmpty) return;

    double stepX = size.width / (incomeData.length - 1);

    // Gelir Çizgisi (Yeşil)
    final incomePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final incomePath = Path()
      ..moveTo(0, size.height - (incomeData[0] * size.height));

    // Gider Çizgisi (Kırmızı)
    final expensePaint = Paint()
      ..color = AppColors.barnRed
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final expensePath = Path()
      ..moveTo(0, size.height - (expenseData[0] * size.height));

    for (int i = 0; i < incomeData.length - 1; i++) {
      double x1 = i * stepX;
      double x2 = (i + 1) * stepX;

      // Gelir Eğrisi
      double y1Inc = size.height - (incomeData[i] * size.height);
      double y2Inc = size.height - (incomeData[i + 1] * size.height);
      incomePath.cubicTo(
        x1 + (x2 - x1) / 2,
        y1Inc,
        x1 + (x2 - x1) / 2,
        y2Inc,
        x2,
        y2Inc,
      );

      // Gider Eğrisi
      double y1Exp = size.height - (expenseData[i] * size.height);
      double y2Exp = size.height - (expenseData[i + 1] * size.height);
      expensePath.cubicTo(
        x1 + (x2 - x1) / 2,
        y1Exp,
        x1 + (x2 - x1) / 2,
        y2Exp,
        x2,
        y2Exp,
      );
    }

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);

    // Noktalar
    final dotPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    for (int i = 0; i < incomeData.length; i++) {
      canvas.drawCircle(
        Offset(i * stepX, size.height - (incomeData[i] * size.height)),
        6,
        incomePaint,
      );
      canvas.drawCircle(
        Offset(i * stepX, size.height - (incomeData[i] * size.height)),
        4,
        dotPaint,
      );

      canvas.drawCircle(
        Offset(i * stepX, size.height - (expenseData[i] * size.height)),
        6,
        expensePaint,
      );
      canvas.drawCircle(
        Offset(i * stepX, size.height - (expenseData[i] * size.height)),
        4,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

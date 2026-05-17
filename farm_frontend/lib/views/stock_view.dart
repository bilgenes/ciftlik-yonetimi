import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../core/ui_helper.dart';

// --- STOK VERİ MODELLERİ ---
class StockTransaction {
  String id;
  String productName; // Süt, Yem, Saman, Silaj
  double amount;
  String unit; // Litre, Kg, Ton, Balya
  double cost; // Maliyet (Finansa Düşecek)
  DateTime date;
  String type; // 'Alım', 'Üretim', 'Tüketim'

  StockTransaction({
    required this.id,
    required this.productName,
    required this.amount,
    required this.unit,
    required this.cost,
    required this.date,
    required this.type,
  });
}

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  State<StockView> createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  // --- MEVCUT STOKLAR (Kg, Litre, Balya cinsinden tutulur) ---
  final Map<String, double> _currentStocks = {
    'Süt': 850.0, // Litre
    'Yem': 2500.0, // Kg
    'Saman': 120.0, // Balya
    'Silaj': 5200.0, // Kg
  };

  // --- GEÇMİŞ İŞLEMLER MOCK VERİSİ ---
  final List<StockTransaction> _transactions = [
    StockTransaction(
      id: '1',
      productName: 'Yem',
      amount: 1500,
      unit: 'Kg',
      cost: 12000,
      date: DateTime.now().subtract(const Duration(days: 2)),
      type: 'Alım',
    ),
    StockTransaction(
      id: '2',
      productName: 'Saman',
      amount: 50,
      unit: 'Balya',
      cost: 2500,
      date: DateTime.now().subtract(const Duration(days: 5)),
      type: 'Alım',
    ),
    StockTransaction(
      id: '3',
      productName: 'Silaj',
      amount: 3,
      unit: 'Ton',
      cost: 9000,
      date: DateTime.now().subtract(const Duration(days: 10)),
      type: 'Alım',
    ),
    StockTransaction(
      id: '4',
      productName: 'Süt',
      amount: 450,
      unit: 'Litre',
      cost: 0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: 'Üretim',
    ),
  ];

  // --- BİRİM VE TON/KG DÖNÜŞÜM YARDIMCISI ---
  String _formatStockDisplay(String product, double amount) {
    if (product == 'Süt') return '${amount.toStringAsFixed(0)} Litre';
    if (product == 'Saman') return '${amount.toStringAsFixed(0)} Balya';

    // Yem ve Silaj için Kg / Ton mantığı
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)} Ton';
    } else {
      return '${amount.toStringAsFixed(0)} Kg';
    }
  }

  // --- POP-UP: STOK GİRİŞİ FORMU ---
  void _showAddStockForm() {
    final amountCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String selectedProduct = 'Yem';
    String selectedUnit = 'Kg'; // Süt->Litre, Saman->Balya, Yem/Silaj->Kg/Ton
    String transactionType = 'Alım'; // Alım (Gider) veya Üretim (Bedelsiz)

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          // Ürüne göre birim listesini dinamik ayarlama
          List<String> availableUnits = ['Kg', 'Ton'];
          if (selectedProduct == 'Süt') availableUnits = ['Litre'];
          if (selectedProduct == 'Saman') availableUnits = ['Balya'];
          if (!availableUnits.contains(selectedUnit))
            selectedUnit = availableUnits.first;

          // Eğer üretimse maliyet 0'dır
          if (transactionType == 'Üretim') costCtrl.text = '0';

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              // KESİN ÇÖZÜM: Klavye yüksekliği + Telefon alt çubuğu
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom +
                  24,
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
                const Text(
                  '📦 Stok Girişi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Comfortaa',
                  ),
                ),
                const SizedBox(height: 20),

                // KAYDIRILABİLİR İÇERİK ALANI
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // İşlem Türü (Alım vs Üretim)
                        Row(
                          children: [
                            Expanded(
                              child: _buildChoiceChip(
                                'Alım (Gider)',
                                transactionType == 'Alım',
                                () => setModalState(
                                  () => transactionType = 'Alım',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildChoiceChip(
                                'Üretim',
                                transactionType == 'Üretim',
                                () => setModalState(
                                  () => transactionType = 'Üretim',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Ürün Seçimi
                        DropdownButtonFormField<String>(
                          value: selectedProduct,
                          decoration: _premiumInputDeco(
                            'Ürün',
                            Icons.category_rounded,
                          ),
                          items: ['Süt', 'Yem', 'Saman', 'Silaj']
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(
                                    p,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => selectedProduct = val!),
                        ),
                        const SizedBox(height: 15),

                        // Miktar ve Birim Yan Yana
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: amountCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _premiumInputDeco(
                                  'Miktar',
                                  Icons.scale_rounded,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                value: selectedUnit,
                                decoration: _premiumInputDeco(
                                  'Birim',
                                  Icons.square_foot_rounded,
                                ),
                                items: availableUnits
                                    .map(
                                      (u) => DropdownMenuItem(
                                        value: u,
                                        child: Text(
                                          u,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) =>
                                    setModalState(() => selectedUnit = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Maliyet (Eğer alım ise)
                        if (transactionType == 'Alım')
                          TextField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _premiumInputDeco(
                              'Toplam Maliyet (₺)',
                              Icons.payments_rounded,
                            ),
                          ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // SABİT BUTON İÇİN BEYAZLIK VE KORUMA BÖLGESİ
                const Divider(color: AppColors.black, thickness: 2, height: 30),
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
                    onPressed: () {
                      if (amountCtrl.text.isNotEmpty) {
                        double amount = double.tryParse(amountCtrl.text) ?? 0;
                        double cost = double.tryParse(costCtrl.text) ?? 0;

                        // Ton girildiyse arka planda Kg olarak kaydet
                        double saveAmount = amount;
                        if (selectedUnit == 'Ton') saveAmount = amount * 1000;

                        setState(() {
                          // Stoğa ekle
                          _currentStocks[selectedProduct] =
                              (_currentStocks[selectedProduct] ?? 0) +
                              saveAmount;
                          // Geçmişe yaz
                          _transactions.insert(
                            0,
                            StockTransaction(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              productName: selectedProduct,
                              amount: amount,
                              unit: selectedUnit,
                              cost: cost,
                              date: DateTime.now(),
                              type: transactionType,
                            ),
                          );
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✅ Stok başarıyla eklendi, maliyet finansa yansıtıldı!',
                            ),
                            backgroundColor: AppColors.primaryGreen,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Stoklara Ekle',
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
          );
        },
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.black : AppColors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.black, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  InputDecoration _premiumInputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.black),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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

  // --- STOK KARTI TASARIMI ---
  Widget _buildStockCard(
    String title,
    double amount,
    LinearGradient bgGradient,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.white, size: 28),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _formatStockDisplay(title, amount),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStockForm,
        backgroundColor: AppColors.primaryGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.black, width: 3),
        ),
        icon: const Icon(
          Icons.add_shopping_cart_rounded,
          color: AppColors.white,
        ),
        label: const Text(
          'Alım Yap / Stok Ekle',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // BAŞLIK
          const Text(
            'Güncel Depo',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              fontFamily: 'Comfortaa',
            ),
          ),
          Text(
            'Depodaki varlıkların ve tüketim tahmini.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),

          // 4'LÜ STOK KARTLARI (GRID)
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              _buildStockCard(
                'Süt',
                _currentStocks['Süt']!,
                AppColors.blackGradient,
                Icons.water_drop_rounded,
              ),
              _buildStockCard(
                'Yem',
                _currentStocks['Yem']!,
                AppColors.yellowGradient,
                Icons.inventory_2_rounded,
              ),
              _buildStockCard(
                'Saman',
                _currentStocks['Saman']!,
                AppColors.redGradient,
                Icons.grass_rounded,
              ),
              _buildStockCard(
                'Silaj',
                _currentStocks['Silaj']!,
                AppColors.greenGradient,
                Icons.eco_rounded,
              ),
            ],
          ),

          const SizedBox(height: 35),

          // GEÇMİŞ İŞLEMLER BAŞLIĞI
          Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.strawYellow,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Geçmiş Alım ve Hareketler',
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

          // İŞLEM GEÇMİŞİ LİSTESİ
          ..._transactions
              .map(
                (t) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.black, width: 2),
                  ),
                  child: Row(
                    children: [
                      // İkon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: t.type == 'Alım'
                              ? AppColors.barnRed.withOpacity(0.1)
                              : AppColors.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          t.type == 'Alım'
                              ? Icons.shopping_cart_rounded
                              : Icons.precision_manufacturing_rounded,
                          color: t.type == 'Alım'
                              ? AppColors.barnRed
                              : AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // Detaylar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  t.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    t.type,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('dd MMM yyyy', 'tr_TR').format(t.date)} • ${t.amount} ${t.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Fiyat
                      if (t.cost > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Maliyet',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₺${t.cost.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.barnRed,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Bedelsiz',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                    ],
                  ),
                ),
              )
              .toList(),

          const SizedBox(height: 80), // FAB Butonu üstüne binmesin diye boşluk
        ],
      ),
    );
  }
}

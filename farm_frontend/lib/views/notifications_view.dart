import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../core/ui_helper.dart';

// --- BİLDİRİM VERİ MODELİ ---
class FarmNotification {
  final String id;
  final String title;
  final String message;
  final DateTime date;
  final String type; // 'health', 'stock', 'system', 'finance'
  bool isRead;

  FarmNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
  });

  // Zaman formatlayıcı (Örn: 2 saat önce, Dün, 15 Mayıs)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) return '${difference.inMinutes} dk önce';
    if (difference.inHours < 24) return '${difference.inHours} saat önce';
    if (difference.inDays == 1) return 'Dün';
    return DateFormat('dd MMM', 'tr_TR').format(date);
  }

  // Türe göre renk
  Color get color {
    switch (type) {
      case 'health':
        return AppColors.barnRed;
      case 'stock':
        return AppColors.strawYellow;
      case 'finance':
        return AppColors.primaryGreen;
      default:
        return AppColors.black;
    }
  }

  // Türe göre ikon
  IconData get icon {
    switch (type) {
      case 'health':
        return Icons.medical_services_rounded;
      case 'stock':
        return Icons.inventory_2_rounded;
      case 'finance':
        return Icons.payments_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  int _currentTab = 0; // 0: Okunmadı, 1: Okundu

  // --- MOCK BİLDİRİMLER ---
  final List<FarmNotification> _notifications = [
    FarmNotification(
      id: '1',
      title: 'Aşı Vakti Geldi!',
      type: 'health',
      message:
          'TR-1122 Sarıkız adlı ineğin planlanmış "Kuru Dönem Aşısı" için bugün son gün. Lütfen aşıyı uygulayıp Sağlık Durumları sekmesinden sisteme işleyin.',
      date: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    FarmNotification(
      id: '2',
      title: 'Kritik Stok Uyarısı',
      type: 'stock',
      message:
          'Hazır Yem deponuzda 200 Kg altı ürün kaldı. Önümüzdeki 3 gün içinde yem tedariği yapmanız önerilir.',
      date: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    FarmNotification(
      id: '3',
      title: 'Yeni Buzağı Kaydı',
      type: 'system',
      message:
          'Sisteme 1 adet yeni buzağı kaydı başarıyla eklendi. Düve kategorisine geçiş tarihleri ajandaya işlendi.',
      date: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    FarmNotification(
      id: '4',
      title: 'Aylık Kar Raporu Hazır',
      type: 'finance',
      isRead: true,
      message:
          'Geçtiğimiz ayın finansal analizleri tamamlandı. Toplam %12 kar artışı sağladınız. Detaylar için Finans Analiz sekmesini inceleyin.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FarmNotification(
      id: '5',
      title: 'Veteriner Kontrolü Tamamlandı',
      type: 'health',
      isRead: true,
      message:
          'TR-9988 Benekli adlı hayvanın Mastit tedavisi başarıyla sonuçlandı ve İyileşti olarak işaretlendi.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Filtrelenmiş Listeler
  List<FarmNotification> get _unreadList =>
      _notifications.where((n) => !n.isRead).toList();
  List<FarmNotification> get _readList =>
      _notifications.where((n) => n.isRead).toList();

  // Tümünü Okundu İşaretle
  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tüm bildirimler okundu işaretlendi!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  // --- POPUP: BİLDİRİM DETAYLARI ---
  void _showNotificationDetails(FarmNotification notif) {
    // Tıklanınca otomatik okundu yap
    setState(() => notif.isRead = true);

    UiHelper.showPremiumBottomSheet(
      context: context,
      child: Container(
        padding: const EdgeInsets.all(24),
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
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 25),

            // Başlık ve İkon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notif.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: notif.color, width: 2),
                  ),
                  child: Icon(notif.icon, color: notif.color, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                          fontFamily: 'Comfortaa',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd MMMM yyyy - HH:mm',
                          'tr_TR',
                        ).format(notif.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),
            const Divider(color: AppColors.black, thickness: 2),
            const SizedBox(height: 15),

            // Mesaj İçeriği
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.black, width: 2),
              ),
              child: Text(
                notif.message,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: AppColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 35),

            // Kapat Butonu
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Anladım, Kapat',
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
  }

  // --- ÖZEL SEKME BUTONU ---
  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Okunmadı',
                      style: TextStyle(
                        color: _currentTab == 0
                            ? AppColors.white
                            : AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Comfortaa',
                      ),
                    ),
                    if (_unreadList.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.barnRed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${_unreadList.length}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
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
                  'Okundu',
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

  // --- BİLDİRİM KARTI ---
  Widget _buildNotificationCard(FarmNotification notif) {
    return InkWell(
      onTap: () => _showNotificationDetails(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notif.isRead
              ? AppColors.white.withOpacity(0.6)
              : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.black,
            width: notif.isRead ? 1.5 : 2.5,
          ),
          boxShadow: notif.isRead
              ? []
              : const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // İkon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notif.color.withOpacity(notif.isRead ? 0.05 : 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: notif.color.withOpacity(notif.isRead ? 0.3 : 1.0),
                  width: 2,
                ),
              ),
              child: Icon(
                notif.icon,
                color: notif.color.withOpacity(notif.isRead ? 0.5 : 1.0),
                size: 24,
              ),
            ),
            const SizedBox(width: 15),

            // İçerik
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: notif.isRead
                                ? AppColors.black.withOpacity(0.5)
                                : AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        notif.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: notif.isRead
                              ? Colors.grey
                              : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.black.withOpacity(
                        notif.isRead ? 0.4 : 0.7,
                      ),
                      fontWeight: notif.isRead
                          ? FontWeight.normal
                          : FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Okunmadı Noktası
            if (!notif.isRead)
              Container(
                margin: const EdgeInsets.only(left: 10, top: 5),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.barnRed,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<FarmNotification> displayList = _currentTab == 0
        ? _unreadList
        : _readList;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Başlık ve Tümünü Okundu İşaretle Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bildirim Merkezi',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    fontFamily: 'Comfortaa',
                  ),
                ),
                if (_currentTab == 0 && _unreadList.isNotEmpty)
                  InkWell(
                    onTap: _markAllAsRead,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.checklist_rtl_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Tümünü Oku',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            _buildCustomTabBar(),
            const SizedBox(height: 10),

            // LİSTE ALANI
            Expanded(
              child: displayList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 80,
                            color: AppColors.black.withOpacity(0.1),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            _currentTab == 0
                                ? 'Harika! Yeni bildirim yok.'
                                : 'Henüz okunan bildirim yok.',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) =>
                          _buildNotificationCard(displayList[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

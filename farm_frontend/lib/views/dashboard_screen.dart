import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_view.dart';
import 'cows_view.dart';
import 'daily_log_view.dart';
import 'agenda_view.dart';
import 'health_view.dart';
import 'stock_view.dart';
import 'finance_view.dart';
import 'notifications_view.dart';
import 'analysis_view.dart';
import 'settings_view.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Tüm renk paletine dağıtılmış menü
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Ana Menü',
      'icon': Icons.dashboard_rounded,
      'color': AppColors.black,
    },
    {
      'title': 'Ajanda',
      'icon': Icons.calendar_month_rounded,
      'color': AppColors.strawYellow,
    },
    {
      'title': 'İneklerim',
      'icon': Icons.grass,
      'color': AppColors.primaryGreen,
    },
    {
      'title': 'Günlük Sayfam',
      'icon': Icons.edit_note_rounded,
      'color': AppColors.black,
    },
    {
      'title': 'Sağlık Durumları',
      'icon': Icons.health_and_safety_rounded,
      'color': AppColors.secondaryPink,
    },
    {
      'title': 'Stok Takip',
      'icon': Icons.inventory_2_rounded,
      'color': AppColors.strawYellow,
    },
    {
      'title': 'Finans',
      'icon': Icons.monetization_on_rounded,
      'color': AppColors.black,
    },
    {
      'title': 'Bildirimler',
      'icon': Icons.notifications_active_rounded,
      'color': AppColors.barnRed,
    },
    {
      'title': 'Analiz',
      'icon': Icons.analytics_rounded,
      'color': AppColors.primaryGreen,
    },
    {'title': 'Ayarlar', 'icon': Icons.settings_rounded, 'color': Colors.grey},
  ];

  late final List<Widget> _pages = [
    HomeView(
      onNavigate: (index) {
        setState(() {
          _selectedIndex =
              index; // Hızlı Erişim butonuna basılınca sayfayı değiştirir
        });
      },
    ),
    const AgendaView(),
    const CowsView(),
    const DailyLogView(),
    const HealthView(),
    const StockView(),
    const FinanceView(),
    const NotificationsView(),
    const AnalysisView(),
    const SettingsView(),
  ];

  Future<void> _handleLogout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.black, // Siyah üst bar
        foregroundColor: AppColors.white,
        title: Text(
          _menuItems[_selectedIndex]['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Comfortaa',
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.notes_rounded,
            size: 30,
            color: AppColors.white,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'ayarlar') {
                setState(() => _selectedIndex = 9);
              } else if (value == 'cikis') {
                _handleLogout();
              }
            },
            offset: const Offset(0, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ayarlar',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: AppColors.black),
                    SizedBox(width: 10),
                    Text('Ayarlar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cikis',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.barnRed),
                    SizedBox(width: 10),
                    Text(
                      'Çıkış Yap',
                      style: TextStyle(
                        color: AppColors.barnRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.strawYellow,
                    width: 2,
                  ), // Siyah barda sarı çerçeve
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  radius: 20,
                  child: Text(
                    'EN',
                    style: TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      drawer: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.only(left: 12, top: 40, bottom: 40),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Drawer(
            elevation: 0,
            backgroundColor: AppColors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    bottom: 30,
                    left: 24,
                    right: 24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: AppColors.blackGradient,
                  ), // Menü başlığı siyah gradient
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text(
                        'Çiftlik Paneli',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Comfortaa',
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      final bool isSelected = _selectedIndex == index;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (item['color'] as Color).withOpacity(0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? Border.all(
                                  color: (item['color'] as Color).withOpacity(
                                    0.3,
                                  ),
                                  width: 1,
                                )
                              : Border.all(color: Colors.transparent),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? item['color']
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: isSelected
                                  ? AppColors.white
                                  : const Color.fromARGB(
                                      255,
                                      0,
                                      0,
                                      0,
                                    ).withOpacity(0.6),
                              size: 22,
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? item['color']
                                  : AppColors.black.withOpacity(0.8),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onTap: () {
                            setState(() => _selectedIndex = index);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
                // OTURUMU KAPAT BUTONU TAMAMEN KALDIRILDI
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false, // Üst kısmı zaten AppBar pürüzsüzce koruyor
        bottom:
            true, // Alttaki telefon menüsüyle çakışmayı küresel olarak engeller
        child: _pages[_selectedIndex],
      ),
    );
  }
}

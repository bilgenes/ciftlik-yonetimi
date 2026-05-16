import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../core/app_colors.dart';

class AgendaEvent {
  final String title;
  final String type; // 'not', 'sistem', 'hedef'
  final Color color;
  final IconData icon;

  AgendaEvent(this.title, this.type, this.color, this.icon);
}

class Goal {
  final String title;
  final DateTime? deadline;
  bool isCompleted;

  Goal(this.title, this.deadline, this.isCompleted);
}

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Çiftlik Canlılığındaki Olay Listesi
  final Map<DateTime, List<AgendaEvent>> _events = {
    DateTime.now(): [
      AgendaEvent(
        'TR1234 kodlu Sarıkız tahmini doğum yapacak! 🐮',
        'sistem',
        AppColors.secondaryPink,
        Icons.child_care_rounded,
      ),
    ],
    DateTime.now().add(const Duration(days: 1)): [
      AgendaEvent(
        'Saman ambarı havalandırma kontrolü. 🌾',
        'not',
        AppColors.black,
        Icons.wb_sunny_rounded,
      ),
      AgendaEvent(
        'Güneydoğu çitlerini ahır kırmızısına boya.',
        'hedef',
        AppColors.barnRed,
        Icons.colorize_rounded,
      ),
    ],
    DateTime.now().add(const Duration(days: 3)): [
      AgendaEvent(
        'Buzağınız 2.5 aylık oldu! Sütten kesme vakti. 🥛',
        'sistem',
        AppColors.primaryGreen,
        Icons.grass_rounded,
      ),
    ],
  };

  final List<Goal> _goals = [
    Goal(
      'Süt verimini günlük 500L üzerine çıkar 📈',
      DateTime.now().add(const Duration(days: 15)),
      false,
    ),
    Goal(
      'Sol koridor zeminini yenile 🛠️',
      DateTime.now().add(const Duration(days: 5)),
      false,
    ),
    Goal('Bahar aşılarını eksiksiz tamamla 💉', null, true),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<AgendaEvent> _getEventsForDay(DateTime day) {
    for (var date in _events.keys) {
      if (isSameDay(date, day)) {
        return _events[date]!;
      }
    }
    return [];
  }

  // --- POPUP: NOT EKLEME PENCERESİ ---
  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.black, width: 3),
        ),
        title: const Text(
          '📝 Yeni Çiftlik Notu',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        content: TextField(
          controller: titleController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Örn: Traktörün yağ değişimi yapılacak...',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.black, width: 2),
            ),
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
              backgroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _events[_selectedDay!] ??= [];
                  _events[_selectedDay!]!.add(
                    AgendaEvent(
                      titleController.text,
                      'not',
                      AppColors.black,
                      Icons.edit_note_rounded,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Kaydet',
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

  // --- POPUP: HEDEF EKLEME PENCERESİ ---
  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AppColors.black, width: 3),
        ),
        title: const Text(
          '🎯 Çiftlik Hedefi Koy',
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: 'Örn: Bu ay 5 ton yonca depola...',
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.black, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Vazgeç',
              style: TextStyle(
                color: AppColors.barnRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.strawYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: AppColors.black, width: 2),
              ),
            ),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _goals.add(
                    Goal(
                      titleController.text,
                      DateTime.now().add(const Duration(days: 7)),
                      false,
                    ),
                  );
                  // Takvime de sarı hedef ikonu olarak fırlatıyoruz
                  _events[_selectedDay!] ??= [];
                  _events[_selectedDay!]!.add(
                    AgendaEvent(
                      titleController.text,
                      'hedef',
                      AppColors.strawYellow,
                      Icons.flag_rounded,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Hedef Belirle',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PREMIUM SİYAH-BEYAZ KESKİN HATLI VE CANLI İÇERİKLİ TAKVİM
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: AppColors.black,
                width: 3,
              ), // Güçlü Premium Siyah Çerçeve
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              rowHeight: 62,

              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Comfortaa',
                ),
                leftChevronIcon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.black,
                  size: 20,
                ),
                rightChevronIcon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.black,
                  size: 20,
                ),
              ),

              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                defaultTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                weekendTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.barnRed,
                ),

                // Bugünün kutusu (Çiftlik Yeşili Parlaması)
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),

                // Seçilen günün kutusu (Premium Siyah)
                selectedDecoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),

                // Olay bildirim noktaları
                markerDecoration: const BoxDecoration(
                  color: AppColors.barnRed,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
            ),
          ),

          const SizedBox(height: 25),

          // AKSİYON BUTONLARI (KÖY CANLILIĞI)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _showAddNoteDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.black, width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.edit_note_rounded,
                          color: AppColors.black,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Not Ekle',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: InkWell(
                  onTap: _showAddGoalDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: AppColors.yellowGradient,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.black, width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.flag_rounded,
                          color: AppColors.black,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hedef Koy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 35),

          // GÜNÜN OLAYLARI BAŞLIĞI
          Row(
            children: [
              Container(
                width: 6,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.barnRed,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_selectedDay!.day}/${_selectedDay!.month} Gündemi',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  fontFamily: 'Comfortaa',
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ..._buildEventList(),

          const SizedBox(height: 35),

          // HEDEFLERİM BAŞLIĞI
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
                'Büyük Hedefler',
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
          ..._goals.map((goal) => _buildGoalCard(goal)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _buildEventList() {
    final events = _getEventsForDay(_selectedDay!);
    if (events.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.black, width: 1.5),
          ),
          alignment: Alignment.center,
          child: const Text(
            '🌾 Bu gün sakin geçiyor, planlanan bir olay yok.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
      ];
    }

    return events
        .map(
          (event) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.black,
                width: 2.5,
              ), // Kalın premium çerçeve
              boxShadow: [
                BoxShadow(
                  color: event.color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(event.icon, color: event.color, size: 26),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList();
  }

  Widget _buildGoalCard(Goal goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: goal.isCompleted ? AppColors.white : AppColors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.black, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 6)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: InkWell(
          onTap: () => setState(() => goal.isCompleted = !goal.isCompleted),
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: goal.isCompleted
                  ? AppColors.primaryGreen
                  : Colors.transparent,
              border: Border.all(
                color: goal.isCompleted
                    ? AppColors.primaryGreen
                    : (goal.isCompleted ? AppColors.black : AppColors.white),
                width: 2.5,
              ),
              shape: BoxShape.circle,
            ),
            child: goal.isCompleted
                ? const Icon(Icons.check, size: 16, color: AppColors.white)
                : null,
          ),
        ),
        title: Text(
          goal.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: goal.isCompleted ? AppColors.black : AppColors.white,
            decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: goal.deadline != null
            ? Text(
                'Kalan Zaman: ${goal.deadline!.day}/${goal.deadline!.month}',
                style: TextStyle(
                  color: goal.isCompleted ? Colors.grey : AppColors.strawYellow,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
    );
  }
}

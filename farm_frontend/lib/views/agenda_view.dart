import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../providers/agenda_provider.dart';

// Riverpod ConsumerStatefulWidget entegrasyonu
class AgendaView extends ConsumerStatefulWidget {
  const AgendaView({super.key});

  @override
  ConsumerState<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends ConsumerState<AgendaView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // Tiplere göre ikon ve renk ataması
  Color _getColorForType(String type) {
    if (type == 'hedef') return AppColors.barnRed;
    if (type == 'sistem') return AppColors.secondaryPink;
    if (type == 'not') return AppColors.black;
    return AppColors.primaryGreen;
  }

  IconData _getIconForType(String type) {
    if (type == 'hedef') return Icons.colorize_rounded;
    if (type == 'sistem') return Icons.child_care_rounded;
    if (type == 'not') return Icons.edit_note_rounded;
    return Icons.event;
  }

  // Belirli bir günün olaylarını listeler
  List<AgendaEventModel> _getEventsForDay(
    DateTime day,
    List<AgendaEventModel> allEvents,
  ) {
    return allEvents.where((event) => isSameDay(event.date, day)).toList();
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
            onPressed: () async {
              if (titleController.text.isNotEmpty && _selectedDay != null) {
                // Provider üzerinden backend'e gönder
                final success = await ref
                    .read(agendaProvider.notifier)
                    .addEvent(titleController.text, 'not', _selectedDay!);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Not Eklendi!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                }
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
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                // 1 hafta sonrası için deadline veriyoruz
                final deadline = DateTime.now().add(const Duration(days: 7));
                final success = await ref
                    .read(agendaProvider.notifier)
                    .addGoal(titleController.text, deadline);

                // Hedefi aynı zamanda bugüne not olarak da takvime atıyoruz
                if (_selectedDay != null) {
                  await ref
                      .read(agendaProvider.notifier)
                      .addEvent(titleController.text, 'hedef', _selectedDay!);
                }

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hedef Kaydedildi!'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                }
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
    // Canlı Verileri İzliyoruz
    final agendaAsyncValue = ref.watch(agendaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: agendaAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (err, stack) => Center(child: Text('Hata oluştu: $err')),
        data: (agendaData) {
          final events = agendaData.events;
          final goals = agendaData.goals;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // PREMIUM TAKVİM
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: AppColors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: TableCalendar<AgendaEventModel>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => _getEventsForDay(day, events),
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
                    todayDecoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    todayTextStyle: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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

              // AKSİYON BUTONLARI
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
                          border: Border.all(
                            color: AppColors.black,
                            width: 2.5,
                          ),
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
                          border: Border.all(
                            color: AppColors.black,
                            width: 2.5,
                          ),
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
              ..._buildEventList(_getEventsForDay(_selectedDay!, events)),

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
              goals.isEmpty
                  ? const Text(
                      'Henüz belirlenmiş bir hedef yok.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Column(
                      children: goals
                          .map((goal) => _buildGoalCard(goal))
                          .toList(),
                    ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildEventList(List<AgendaEventModel> dayEvents) {
    if (dayEvents.isEmpty) {
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

    return dayEvents.map((event) {
      final color = _getColorForType(event.type);
      final icon = _getIconForType(event.type);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.black, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
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
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
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
      );
    }).toList();
  }

  Widget _buildGoalCard(GoalModel goal) {
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
          onTap: () => ref.read(agendaProvider.notifier).toggleGoal(goal),
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';

// --- MODELLER ---
class AgendaEventModel {
  String? id;
  String title;
  String type; // 'not', 'sistem', 'hedef'
  DateTime date;

  AgendaEventModel({
    this.id,
    required this.title,
    required this.type,
    required this.date,
  });

  factory AgendaEventModel.fromJson(Map<String, dynamic> json) {
    return AgendaEventModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      type: json['type'] ?? 'not',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }
}

class GoalModel {
  String? id;
  String title;
  DateTime? deadline;
  bool isCompleted;

  GoalModel({
    this.id,
    required this.title,
    this.deadline,
    required this.isCompleted,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id']?.toString(),
      title: json['title'] ?? '',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      isCompleted: json['is_completed'] == 1 || json['is_completed'] == true,
    );
  }
}

// --- STATE SINIFI ---
class AgendaData {
  final List<AgendaEventModel> events;
  final List<GoalModel> goals;
  AgendaData({required this.events, required this.goals});
}

// --- PROVIDER ---
class AgendaNotifier extends AsyncNotifier<AgendaData> {
  final DioClient _dioClient = DioClient();

  @override
  Future<AgendaData> build() async {
    return _fetchAgenda();
  }

  // Backend'den Verileri Çeker
  Future<AgendaData> _fetchAgenda() async {
    try {
      final eventsResponse = await _dioClient.dio.get('agenda/events');
      final goalsResponse = await _dioClient.dio.get('agenda/goals');

      List<AgendaEventModel> events = [];
      List<GoalModel> goals = [];

      if (eventsResponse.statusCode == 200) {
        events = (eventsResponse.data as List)
            .map((e) => AgendaEventModel.fromJson(e))
            .toList();
      }
      if (goalsResponse.statusCode == 200) {
        goals = (goalsResponse.data as List)
            .map((e) => GoalModel.fromJson(e))
            .toList();
      }

      return AgendaData(events: events, goals: goals);
    } catch (e) {
      print('Ajanda veri çekme hatası: $e');
      return AgendaData(events: [], goals: []);
    }
  }

  // Not/Olay Ekleme
  Future<bool> addEvent(String title, String type, DateTime date) async {
    try {
      final response = await _dioClient.dio.post(
        'agenda/events',
        data: {'title': title, 'type': type, 'date': date.toIso8601String()},
      );
      if (response.statusCode == 201) {
        ref.invalidateSelf(); // UI'ı yeniler
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Hedef Ekleme
  Future<bool> addGoal(String title, DateTime? deadline) async {
    try {
      final response = await _dioClient.dio.post(
        'agenda/goals',
        data: {
          'title': title,
          'deadline': deadline?.toIso8601String(),
          'is_completed': false,
        },
      );
      if (response.statusCode == 201) {
        ref.invalidateSelf(); // UI'ı yeniler
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Hedef Tamamlanma Durumunu Değiştirme
  Future<bool> toggleGoal(GoalModel goal) async {
    // UI tarafında anında güncellemek için geçici optimistik güncelleme
    final prevCompleted = goal.isCompleted;
    goal.isCompleted = !prevCompleted;
    state = AsyncData(
      AgendaData(events: state.value!.events, goals: state.value!.goals),
    );

    try {
      final response = await _dioClient.dio.put(
        'agenda/goals/${goal.id}/toggle',
        data: {'is_completed': goal.isCompleted},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        // Hata varsa geri al
        goal.isCompleted = prevCompleted;
        state = AsyncData(
          AgendaData(events: state.value!.events, goals: state.value!.goals),
        );
        return false;
      }
    } catch (e) {
      goal.isCompleted = prevCompleted;
      state = AsyncData(
        AgendaData(events: state.value!.events, goals: state.value!.goals),
      );
      return false;
    }
  }
}

final agendaProvider = AsyncNotifierProvider<AgendaNotifier, AgendaData>(
  () => AgendaNotifier(),
);

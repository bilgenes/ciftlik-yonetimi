import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farm_frontend/core/network/dio_client.dart';
import '../views/notifications_view.dart'; // Modelimiz burada duruyor

class NotificationNotifier extends AsyncNotifier<List<FarmNotification>> {
  final DioClient _dioClient = DioClient();

  @override
  Future<List<FarmNotification>> build() async {
    return _fetchNotifications();
  }

  Future<List<FarmNotification>> _fetchNotifications() async {
    try {
      final response = await _dioClient.dio.get('notifications');
      if (response.statusCode == 200) {
        return (response.data as List).map((json) {
          return FarmNotification(
            id: json['id'].toString(),
            title: json['title'],
            message: json['message'],
            type: json['type'],
            isRead: json['is_read'],
            date: DateTime.parse(json['created_at']),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Bildirim Hatası: $e');
      return [];
    }
  }

  Future<void> markAsRead(String id) async {
    // Optimistik güncelleme (UI hemen değişsin)
    final previousState = state.value;
    if (previousState != null) {
      state = AsyncData(
        previousState.map((n) {
          if (n.id == id) n.isRead = true;
          return n;
        }).toList(),
      );
    }

    try {
      await _dioClient.dio.put('notifications/$id/read');
    } catch (e) {
      print('Okundu hatası: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final previousState = state.value;
    if (previousState != null) {
      state = AsyncData(
        previousState.map((n) {
          n.isRead = true;
          return n;
        }).toList(),
      );
    }

    try {
      await _dioClient.dio.put('notifications/read-all');
    } catch (e) {
      print('Tümünü okundu yapma hatası: $e');
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<FarmNotification>>(() {
      return NotificationNotifier();
    });

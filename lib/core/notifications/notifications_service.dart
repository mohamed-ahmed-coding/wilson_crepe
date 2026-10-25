import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _messageSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  void Function(int orderId)? onOrderTap;

  static const _channelId = 'order_notifications';

  NotificationsService(this._supabase);

  Future<void> initialize() async {
    debugPrint('NotificationsService.initialize() called');

    final user = _supabase.auth.currentUser;

    if (user == null) {
      debugPrint('NotificationsService: user is null');
      return;
    }

    await _initializeLocalNotifications();
    await _saveCurrentToken(user.id);

    await _tokenSubscription?.cancel();
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _saveToken(userId: user.id, token: token);
    });

    await _messageSubscription?.cancel();
    _messageSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    await _openedAppSubscription?.cancel();
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleMessageTap,
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessageTap(initialMessage);
      });
    }

    debugPrint('Notification listeners registered');
  }

  void _handleMessageTap(RemoteMessage message) {
    _openOrder(message.data['order_id']);
  }

  void _openOrder(dynamic rawOrderId) {
    final orderId = int.tryParse(rawOrderId?.toString() ?? '');

    if (orderId == null) {
      debugPrint('Notification tap: invalid order_id ($rawOrderId)');
      return;
    }

    debugPrint('Notification tapped, opening order #$orderId');
    onOrderTap?.call(orderId);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _openOrder(response.payload);
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        'Order Notifications',
        description: 'Notifications about order status updates',
        importance: Importance.max,
      ),
    );
  }



  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      debugPrint('Foreground message has no notification payload.');
      return;
    }

    await _showLocalNotification(
      title: notification.title ?? 'Order Update',
      body: notification.body ?? '',
      payload: message.data['order_id']?.toString(),
    );
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Order Notifications',
      channelDescription: 'Notifications about order status updates',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _localNotifications.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Local notification failed: $e');
    }
  }

  Future<void> _saveCurrentToken(String userId) async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM token is null or empty.');
        return;
      }

      await _saveToken(userId: userId, token: token);
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
    }
  }

  Future<void> _saveToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _supabase.from('user_devices').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,fcm_token');
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  Future<void> removeCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _supabase.from('user_devices').delete().eq('fcm_token', token);
      }
    } catch (e) {
      debugPrint('Failed to remove FCM token: $e');
    }
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedAppSubscription?.cancel();

    _tokenSubscription = null;
    _messageSubscription = null;
    _openedAppSubscription = null;
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _prefLunchEnabled = 'notif_lunch_enabled';
  static const String _prefDinnerEnabled = 'notif_dinner_enabled';
  static const String _prefLunchHour = 'notif_lunch_hour';
  static const String _prefLunchMinute = 'notif_lunch_minute';
  static const String _prefDinnerHour = 'notif_dinner_hour';
  static const String _prefDinnerMinute = 'notif_dinner_minute';

  static const int lunchNotificationId = 1001;
  static const int dinnerNotificationId = 1002;
  static const int testNotificationId = 9999;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Timezone 초기화
    try {
      tz.initializeTimeZones();
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      debugPrint('Timezone initialization error: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    // 2. Android / iOS 설정
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // 3. Android 알림 채널 생성 (중요도 HIGH)
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.createNotificationChannel(
        const AndroidNotificationChannel(
          'today_menu_meal_channel',
          '오늘의 메뉴 알림',
          description: '점심 및 저녁 식사 시간 메뉴 추천 알림을 제공합니다.',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _isInitialized = true;

    // 4. 저장된 설정에 따라 일일 알림 스케줄 등록
    await updateSchedules();
  }

  /// 알림 권한 요청
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// 즉시 테스트 알림 발송
  Future<void> sendTestNotification() async {
    await requestPermissions();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'today_menu_meal_channel',
      '오늘의 메뉴 알림',
      channelDescription: '점심 및 저녁 식사 시간 메뉴 추천 알림',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id: testNotificationId,
      title: '오늘 뭐 먹지? 🍽️ [알림 테스트]',
      body: '1초 만에 딱 골라드려요! 점심/저녁 알림이 이렇게 전달됩니다 😋',
      notificationDetails: details,
    );
  }

  /// 점심 & 저녁 예약 알림 갱신
  Future<void> updateSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final lunchEnabled = prefs.getBool(_prefLunchEnabled) ?? true;
    final dinnerEnabled = prefs.getBool(_prefDinnerEnabled) ?? true;
    final lunchHour = prefs.getInt(_prefLunchHour) ?? 11;
    final lunchMinute = prefs.getInt(_prefLunchMinute) ?? 30;
    final dinnerHour = prefs.getInt(_prefDinnerHour) ?? 17;
    final dinnerMinute = prefs.getInt(_prefDinnerMinute) ?? 30;

    // 점심 알림 설정
    if (lunchEnabled) {
      await _scheduleDailyNotification(
        id: lunchNotificationId,
        title: '오늘 점심 뭐 먹지? 🍽️',
        body: '점심 메뉴 아직 안 정하셨죠? 1초 만에 딱 골라드릴게요!',
        hour: lunchHour,
        minute: lunchMinute,
      );
    } else {
      await _notificationsPlugin.cancel(id: lunchNotificationId);
    }

    // 저녁 알림 설정
    if (dinnerEnabled) {
      await _scheduleDailyNotification(
        id: dinnerNotificationId,
        title: '오늘 저녁 메뉴 고민 끝! 🍕',
        body: '오늘 하루도 수고 많으셨어요! 맛있는 저녁 메뉴 골라보세요 😋',
        hour: dinnerHour,
        minute: dinnerMinute,
      );
    } else {
      await _notificationsPlugin.cancel(id: dinnerNotificationId);
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'today_menu_meal_channel',
        '오늘의 메뉴 알림',
        channelDescription: '점심 및 저녁 식사 시간 메뉴 추천 알림',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Schedule notification error: $e');
    }
  }

  // Getters & Setters for preferences
  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'lunchEnabled': prefs.getBool(_prefLunchEnabled) ?? true,
      'dinnerEnabled': prefs.getBool(_prefDinnerEnabled) ?? true,
      'lunchHour': prefs.getInt(_prefLunchHour) ?? 11,
      'lunchMinute': prefs.getInt(_prefLunchMinute) ?? 30,
      'dinnerHour': prefs.getInt(_prefDinnerHour) ?? 17,
      'dinnerMinute': prefs.getInt(_prefDinnerMinute) ?? 30,
    };
  }

  Future<void> saveSettings({
    required bool lunchEnabled,
    required bool dinnerEnabled,
    required int lunchHour,
    required int lunchMinute,
    required int dinnerHour,
    required int dinnerMinute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLunchEnabled, lunchEnabled);
    await prefs.setBool(_prefDinnerEnabled, dinnerEnabled);
    await prefs.setInt(_prefLunchHour, lunchHour);
    await prefs.setInt(_prefLunchMinute, lunchMinute);
    await prefs.setInt(_prefDinnerHour, dinnerHour);
    await prefs.setInt(_prefDinnerMinute, dinnerMinute);

    await updateSchedules();
  }
}

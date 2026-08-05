import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import '../router/app_router.dart';

/// Schedules daily local reminders at 09:00 and 18:00 (device local time).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _permissionAskedKey = 'notifications_permission_asked';
  static const _localeKey = 'app_locale';

  static const _morningId = 1;
  static const _eveningId = 2;
  static const _testId = 99;

  static const _channelId = 'daily_reminders';
  static const _channelName = 'Daily reminders';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _configureLocalTimeZone();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _navigateToPoints();
    }

    _initialized = true;
  }

  /// Ask permission once after splash, then schedule if granted.
  Future<void> ensureScheduled([Locale? locale]) async {
    if (!_initialized) await init();

    final effectiveLocale = locale ?? await _loadLocaleFromPrefs();
    final granted = await hasPermission();
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool(_permissionAskedKey) ?? false;

    if (!granted && !asked) {
      final newGranted = await requestPermission();
      await prefs.setBool(_permissionAskedKey, true);
      if (!newGranted) return;
    } else if (!granted) {
      return;
    }

    await scheduleDailyReminders(effectiveLocale);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
      await android.requestExactAlarmsPermission();
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return hasPermission();
  }

  Future<bool> hasPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final enabled = await android.areNotificationsEnabled();
      return enabled ?? true;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final settings = await ios.checkPermissions();
      return settings?.isEnabled ?? false;
    }

    return false;
  }

  Future<void> scheduleDailyReminders(Locale locale) async {
    if (!_initialized) await init();
    if (!await hasPermission()) return;

    final l10n = lookupAppLocalizations(locale);

    await _plugin.cancel(_morningId);
    await _plugin.cancel(_eveningId);

    await _scheduleDaily(
      id: _morningId,
      hour: 9,
      minute: 0,
      title: l10n.notificationMorningTitle,
      body: l10n.notificationMorningBody,
    );
    await _scheduleDaily(
      id: _eveningId,
      hour: 18,
      minute: 0,
      title: l10n.notificationEveningTitle,
      body: l10n.notificationEveningBody,
    );

    if (kDebugMode) {
      debugPrint(
        'Daily reminders scheduled (${locale.languageCode}) at 09:00 and 18:00',
      );
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Debug-only: fire a single notification after [delay].
  Future<void> scheduleTestNotification(
    Locale locale, {
    Duration delay = const Duration(seconds: 60),
  }) async {
    if (!kDebugMode) return;
    if (!_initialized) await init();
    if (!await hasPermission()) {
      debugPrint('Test notification skipped: permission not granted');
      return;
    }

    final l10n = lookupAppLocalizations(locale);
    final scheduled = tz.TZDateTime.now(tz.local).add(delay);

    await _plugin.zonedSchedule(
      _testId,
      l10n.notificationMorningTitle,
      '${l10n.notificationMorningBody} (test)',
      scheduled,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('Test notification scheduled in ${delay.inSeconds}s');
  }

  /// Debug-only: show morning notification immediately (same copy as 09:00).
  Future<void> fireMorningNow([Locale locale = const Locale('tr')]) async {
    if (!kDebugMode) return;
    await _showNow(
      id: _testId,
      title: lookupAppLocalizations(locale).notificationMorningTitle,
      body: lookupAppLocalizations(locale).notificationMorningBody,
      label: 'morning',
    );
  }

  /// Debug-only: show evening notification immediately (same copy as 18:00).
  Future<void> fireEveningNow([Locale locale = const Locale('tr')]) async {
    if (!kDebugMode) return;
    await _showNow(
      id: _testId + 1,
      title: lookupAppLocalizations(locale).notificationEveningTitle,
      body: lookupAppLocalizations(locale).notificationEveningBody,
      label: 'evening',
    );
  }

  /// Debug-only: morning in [morningDelay], evening in [eveningDelay].
  Future<void> fireMorningAndEveningSoon({
    Locale locale = const Locale('tr'),
    Duration morningDelay = const Duration(seconds: 5),
    Duration eveningDelay = const Duration(seconds: 15),
  }) async {
    if (!kDebugMode) return;
    if (!_initialized) await init();
    if (!await hasPermission()) {
      debugPrint('Test notifications skipped: permission not granted');
      return;
    }

    final l10n = lookupAppLocalizations(locale);
    final now = tz.TZDateTime.now(tz.local);

    await _plugin.zonedSchedule(
      _testId,
      l10n.notificationMorningTitle,
      l10n.notificationMorningBody,
      now.add(morningDelay),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
    await _plugin.zonedSchedule(
      _testId + 1,
      l10n.notificationEveningTitle,
      l10n.notificationEveningBody,
      now.add(eveningDelay),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint(
      'Test: morning in ${morningDelay.inSeconds}s, '
      'evening in ${eveningDelay.inSeconds}s',
    );
  }

  Future<void> _showNow({
    required int id,
    required String title,
    required String body,
    required String label,
  }) async {
    if (!_initialized) await init();
    if (!await hasPermission()) {
      debugPrint('Test $label skipped: permission not granted');
      return;
    }

    await _plugin.show(id, title, body, _notificationDetails());
    debugPrint('Test $label notification shown now');
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily zero-waste habit reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  void _configureLocalTimeZone() {
    tz.initializeTimeZones();
    final offset = DateTime.now().timeZoneOffset;
    for (final location in tz.timeZoneDatabase.locations.values) {
      if (tz.TZDateTime.now(location).timeZoneOffset == offset) {
        tz.setLocalLocation(location);
        return;
      }
    }
    tz.setLocalLocation(tz.UTC);
  }

  Future<Locale> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == 'en') return const Locale('en');
    return const Locale('tr');
  }

  void _onNotificationResponse(NotificationResponse response) {
    _navigateToPoints();
  }

  void _navigateToPoints() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(AppRouter.points);
    });
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(
    NotificationResponse response,
  ) {
    // Tap navigation is handled when the app resumes via onDidReceiveNotificationResponse.
  }
}

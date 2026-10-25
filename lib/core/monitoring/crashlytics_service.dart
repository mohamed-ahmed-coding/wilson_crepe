import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  CrashlyticsService._();

  static final CrashlyticsService instance =
      CrashlyticsService._();

  FirebaseCrashlytics get _crashlytics =>
      FirebaseCrashlytics.instance;

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (kIsWeb) return;

    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> log(String message) async {
    if (kIsWeb) return;

    await _crashlytics.log(message);
  }

  Future<void> setUserIdentifier(String? userId) async {
    if (kIsWeb) return;

    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  Future<void> setCustomKey(
    String key,
    Object value,
  ) async {
    if (kIsWeb) return;

    await _crashlytics.setCustomKey(key, value);
  }
}

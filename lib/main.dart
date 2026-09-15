import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app.dart';

import 'src/core/services/ad_service.dart';
import 'src/core/utils/hive_setup.dart';
import 'src/features/notifications/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await HiveSetup.init();

  // Initialize Google Mobile Ads SDK
  await AdService.instance.initialize();

  // Initialize notification service (timezone, channels)
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Request notification permission on first launch
  final isFirstLaunch = await _isFirstLaunch();
  if (isFirstLaunch) {
    await notificationService.requestPermission();
  }

  runApp(
    const ProviderScope(
      child: FinanceEnglishDrillApp(),
    ),
  );
}

/// Check if this is the first launch by reading a flag from Hive
Future<bool> _isFirstLaunch() async {
  try {
    final box = await HiveSetup.openNotificationSettingsBox();
    final hasLaunched = box.get('has_launched', defaultValue: 'false');
    if (hasLaunched != 'true') {
      await box.put('has_launched', 'true');
      return true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

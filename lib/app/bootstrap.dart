import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../infrastructure/logging/file_logger.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Opening or saving a project swaps the database instance, so more than one
  // AppDatabase legitimately exists over a session. The previous one is always
  // closed first, which is the race the warning is about.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  // Initialize Logger & SensitiveFilter
  await FileLogger.instance.init();

  // Initialize Window Manager for Desktop
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1280, 800),
    minimumSize: Size(900, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'LangForge',
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(builder());
}

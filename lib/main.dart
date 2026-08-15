import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/map_screen.dart';

void main() {
  // لوج واضح لأي exception بيحصل في الـ UI (يساعد في تتبّع أي crash)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}\n${details.stack}');
  };

  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const MapRoutePlannerApp());
    },
    (error, stack) => debugPrint('Uncaught error: $error\n$stack'),
  );
}

class MapRoutePlannerApp extends StatelessWidget {
  const MapRoutePlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Route Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

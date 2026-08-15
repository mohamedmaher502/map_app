import 'package:flutter/material.dart';

import 'screens/map_screen.dart';

void main() {
  runApp(const MapRoutePlannerApp());
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

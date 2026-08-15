import 'package:latlong2/latlong.dart';

/// بيانات المسار الراجعة من OSRM
class RouteInfo {
  final List<LatLng> points; // نقاط الـ Polyline
  final double distanceMeters;
  final double durationSeconds;

  const RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// المسافة بصيغة قابلة للعرض: 12.6 km أو 850 m
  String get distanceText {
    if (distanceMeters < 1000) return '${distanceMeters.toStringAsFixed(0)} m';
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km';
  }

  /// الزمن المتوقع: 24 min أو 1 h 12 min
  String get durationText {
    final totalMinutes = (durationSeconds / 60).round();
    if (totalMinutes < 60) return '$totalMinutes min';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }

  factory RouteInfo.fromOsrmJson(Map<String, dynamic> json) {
    final routes = json['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No route found between the two locations.');
    }

    final route = routes.first as Map<String, dynamic>;
    final coords = (route['geometry']['coordinates'] as List<dynamic>)
        // OSRM بيرجّع [lon, lat] فلازم نعكسهم
        .map((c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ))
        .toList();

    return RouteInfo(
      points: coords,
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }
}

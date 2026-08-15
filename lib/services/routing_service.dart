import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/route_info.dart';

class RoutingFailure implements Exception {
  final String message;
  RoutingFailure(this.message);
  @override
  String toString() => message;
}

/// (بند 04 + 07 + 08) جلب المسار الحقيقي + المسافة + الزمن من OSRM API
class RoutingService {
  static const String _base = 'https://router.project-osrm.org/route/v1';

  static Future<RouteInfo> getRoute({
    required LatLng from,
    required LatLng to,
    String profile = 'driving', // driving | walking | cycling
  }) async {
    final coords =
        '${from.longitude},${from.latitude};${to.longitude},${to.latitude}';

    final uri = Uri.parse('$_base/$profile/$coords').replace(queryParameters: {
      'overview': 'full',
      'geometries': 'geojson',
      'steps': 'false',
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) {
        throw RoutingFailure('خطأ من سيرفر المسار (${res.statusCode}).');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['code'] != 'Ok') {
        throw RoutingFailure('مفيش طريق متاح بين النقطتين.');
      }

      return RouteInfo.fromOsrmJson(data);
    } on SocketException {
      throw RoutingFailure('مفيش اتصال بالإنترنت.');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/place.dart';

class GeocodingFailure implements Exception {
  final String message;
  GeocodingFailure(this.message);
  @override
  String toString() => message;
}

/// (بند 02) البحث عن مكان بالاسم وتحويله لـ Latitude & Longitude
/// باستخدام Nominatim (OpenStreetMap) Geocoding API
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const String _reverseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  /// Nominatim بيطلب User-Agent واضح، غيّره لاسم تطبيقك
  static const Map<String, String> _headers = {
    'User-Agent': 'MapRoutePlanner/1.0 (flutter-task)',
    'Accept': 'application/json',
  };

  static Future<List<Place>> search(String query, {int limit = 5}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw GeocodingFailure('اكتب اسم المكان الأول.');
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'q': trimmed,
      'format': 'json',
      'addressdetails': '1',
      'limit': '$limit',
    });

    try {
      final res = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 20),
          );

      if (res.statusCode != 200) {
        throw GeocodingFailure('خطأ من سيرفر البحث (${res.statusCode}).');
      }

      final data = jsonDecode(res.body) as List<dynamic>;
      if (data.isEmpty) {
        throw GeocodingFailure('مفيش نتائج للمكان: "$trimmed".');
      }

      return data
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw GeocodingFailure('مفيش اتصال بالإنترنت.');
    }
  }

  /// أول نتيجة فقط (للاستخدام السريع)
  static Future<Place> searchFirst(String query) async {
    final results = await search(query, limit: 1);
    return results.first;
  }

  /// Reverse Geocoding: تحويل إحداثيات لعنوان مقروء
  /// بيُستخدم مع زرار "موقعي الحالي" لعرض اسم المكان بدل أرقام بس
  static Future<String?> reverse(double lat, double lon) async {
    final uri = Uri.parse(_reverseUrl).replace(queryParameters: {
      'lat': '$lat',
      'lon': '$lon',
      'format': 'json',
      'zoom': '16',
    });

    try {
      final res = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 15),
          );
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final name = data['display_name']?.toString();
      if (name == null || name.isEmpty) return null;

      // نرجّع أول 3 أجزاء بس عشان يبان مختصر
      final parts = name.split(',').map((e) => e.trim()).toList();
      return parts.take(3).join(', ');
    } catch (_) {
      // مش خطأ حرج — الموقع بيتعرض عادي بالإحداثيات
      return null;
    }
  }
}

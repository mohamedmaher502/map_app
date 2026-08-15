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
}

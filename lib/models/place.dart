import 'package:latlong2/latlong.dart';

/// نتيجة بحث واحدة راجعة من Nominatim
class Place {
  final String displayName;
  final double lat;
  final double lon;

  const Place({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  LatLng get latLng => LatLng(lat, lon);

  /// اسم مختصر للعرض (أول جزئين من الاسم الكامل)
  String get shortName {
    final parts = displayName.split(',');
    if (parts.length <= 2) return displayName.trim();
    return '${parts.first.trim()}, ${parts.last.trim()}';
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      displayName: (json['display_name'] ?? 'Unknown place').toString(),
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
    );
  }
}

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// استثناء مخصص لأخطاء الموقع (بند 10: Handle Errors)
class LocationFailure implements Exception {
  final String message;

  /// محتاج يفتح إعدادات التطبيق (صلاحية مرفوضة نهائيًا)
  final bool needsAppSettings;

  /// محتاج يشغّل الـ GPS من إعدادات الجهاز
  final bool needsLocationSettings;

  LocationFailure(
    this.message, {
    this.needsAppSettings = false,
    this.needsLocationSettings = false,
  });

  @override
  String toString() => message;
}

class LocationService {
  /// (بند 01) جلب الموقع الحالي بعد التأكد من الصلاحيات و تشغيل GPS
  static Future<LatLng> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationFailure(
        'خدمة الموقع (GPS) مقفولة. من فضلك شغّلها وحاول تاني.',
        needsLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationFailure('تم رفض صلاحية الموقع.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationFailure(
        'صلاحية الموقع مرفوضة نهائيًا. افتح إعدادات التطبيق واسمح بالوصول للموقع.',
        needsAppSettings: true,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      // fallback: آخر موقع معروف
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LatLng(last.latitude, last.longitude);
      throw LocationFailure('مش قادر أحدد موقعك الحالي. جرّب في مكان مفتوح.');
    }
  }

  /// فتح إعدادات التطبيق للسماح بالصلاحية يدويًا
  static Future<void> openAppSettings() => Geolocator.openAppSettings();

  /// فتح إعدادات الموقع (GPS) في الجهاز
  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();
}

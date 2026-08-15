import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// استثناء مخصص لأخطاء الموقع (بند 10: Handle Errors)
class LocationFailure implements Exception {
  final String message;

  /// محتاج يفتح إعدادات التطبيق (صلاحية مرفوضة نهائيًا)
  final bool needsAppSettings;

  /// محتاج يشغّل الـ GPS من إعدادات الجهاز
  final bool needsLocationSettings;

  /// تفاصيل تقنية للمطوّر (سبب الفشل الحقيقي)
  final String? details;

  LocationFailure(
    this.message, {
    this.needsAppSettings = false,
    this.needsLocationSettings = false,
    this.details,
  });

  @override
  String toString() => details == null ? message : '$message\n($details)';
}

class LocationService {
  /// (بند 01) جلب الموقع الحالي بعد التأكد من الصلاحيات و تشغيل GPS
  ///
  /// بيجرّب بالترتيب:
  /// 1) دقة عالية (GPS)
  /// 2) آخر موقع معروف (أسرع حل لو الـ GPS بياخد وقت)
  /// 3) دقة متوسطة (شبكة / Wi-Fi) — بتشتغل جوه المباني
  /// 4) على أندرويد: LocationManager بدل Google Play Services
  ///    (مهم للأجهزة اللي مفيهاش Play Services أو الإيموليتر)
  static Future<LatLng> getCurrentLocation() async {
    // 1) الـ GPS مشغّل؟
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationFailure(
        'خدمة الموقع (GPS) مقفولة. من فضلك شغّلها وحاول تاني.',
        needsLocationSettings: true,
      );
    }

    // 2) الصلاحيات
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

    Object? lastError;

    // 3) محاولة أساسية: دقة عالية
    final fix = await _tryGetPosition(
      const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
      onError: (e) => lastError = e,
    );
    if (fix != null) return fix;

    // 4) آخر موقع معروف (كاش الجهاز)
    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LatLng(last.latitude, last.longitude);
    } catch (e) {
      lastError = e;
    }

    // 5) دقة متوسطة (شبكة الموبايل / Wi-Fi) — بتنفع جوه المباني
    final coarse = await _tryGetPosition(
      const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 20),
      ),
      onError: (e) => lastError = e,
    );
    if (coarse != null) return coarse;

    // 6) أندرويد: تجاهل Google Play Services واستخدم LocationManager
    if (Platform.isAndroid) {
      final legacy = await _tryGetPosition(
        AndroidSettings(
          accuracy: LocationAccuracy.medium,
          forceLocationManager: true,
          timeLimit: const Duration(seconds: 25),
        ),
        onError: (e) => lastError = e,
      );
      if (legacy != null) return legacy;
    }

    throw LocationFailure(
      'مش قادر أحدد موقعك الحالي. اطلع في مكان مفتوح أو تأكد إن الـ GPS '
      'مضبوط على High accuracy، وجرّب تاني.',
      details: lastError?.toString(),
    );
  }

  static Future<LatLng?> _tryGetPosition(
    LocationSettings settings, {
    required void Function(Object error) onError,
  }) async {
    try {
      final p = await Geolocator.getCurrentPosition(locationSettings: settings);
      return LatLng(p.latitude, p.longitude);
    } catch (e) {
      onError(e);
      return null;
    }
  }

  /// تقرير تشخيصي بيساعدك تعرف سبب فشل تحديد الموقع
  static Future<Map<String, String>> diagnostics() async {
    final report = <String, String>{};
    try {
      report['GPS service'] = (await Geolocator.isLocationServiceEnabled())
          ? 'ON'
          : 'OFF';
    } catch (e) {
      report['GPS service'] = 'error: $e';
    }
    try {
      report['Permission'] = (await Geolocator.checkPermission()).name;
    } catch (e) {
      report['Permission'] = 'error: $e';
    }
    try {
      final last = await Geolocator.getLastKnownPosition();
      report['Last known'] = last == null
          ? 'none'
          : '${last.latitude.toStringAsFixed(5)}, '
              '${last.longitude.toStringAsFixed(5)}';
    } catch (e) {
      report['Last known'] = 'error: $e';
    }
    report['Platform'] = Platform.operatingSystem;
    return report;
  }

  /// فتح إعدادات التطبيق للسماح بالصلاحية يدويًا
  static Future<void> openAppSettings() => Geolocator.openAppSettings();

  /// فتح إعدادات الموقع (GPS) في الجهاز
  static Future<void> openLocationSettings() =>
      Geolocator.openLocationSettings();
}

/// (بند 05 + 09) طبقات الخريطة من URLs مختلفة + التبديل بينها
class MapStyle {
  final String name;
  final String urlTemplate;
  final String attribution;
  final List<String> subdomains;


  const MapStyle({
    required this.name,
    required this.urlTemplate,
    required this.attribution,
    this.subdomains = const [],
  });
}


class MapStyles {
  // ملاحظة مهمة: تم التحويل من tile.openstreetmap.org إلى CARTO
  // لأن سيرفر OpenStreetMap الرسمي بيعمل حظر مؤقت (rate limit) على
  // التطبيقات وقت التطوير/التجربة المكثفة، فبتظهر الخريطة بيضاء
  // بالكامل بدون أي خطأ واضح. CARTO بيقدّم نفس بيانات OSM لكن
  // بسياسة استخدام أكثر مرونة للتطبيقات.
  static const standard = MapStyle(
    name: 'Standard',
    urlTemplate:
        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    attribution: '© OpenStreetMap contributors © CARTO',
    subdomains: ['a', 'b', 'c', 'd'],
  );


  static const humanitarian = MapStyle(
    name: 'Humanitarian',
    urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
    attribution: '© OpenStreetMap France, HOT',
    subdomains: ['a', 'b', 'c'],
  );


  static const topo = MapStyle(
    name: 'Topographic',
    urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: '© OpenTopoMap (CC-BY-SA)',
  );


  static const satellite = MapStyle(
    name: 'Satellite',
    urlTemplate:
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Esri, Maxar, Earthstar Geographics',
  );


  static const List<MapStyle> all = [standard, humanitarian, topo, satellite];
}


/// (بند 06) أيقونات الماركرز محمّلة من URLs
class MarkerIcons {
  static const String currentLocation =
      'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png';
  static const String destination =
      'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png';
}

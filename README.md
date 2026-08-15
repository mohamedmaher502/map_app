# Map Route Planner — Flutter Maps App

تطبيق فلاتر للبحث عن أي مكان وجلب المسار الحقيقي للسواقة من موقعك الحالي.

## Features
1. **Get Current Location** — geolocator مع التعامل الكامل مع الصلاحيات و GPS.
2. **Search for a Location** — TextFormField + Nominatim (OpenStreetMap) Geocoding API.
3. **Add Markers** — ماركر أزرق للموقع الحالي وأحمر للوجهة.
4. **Draw Real Route** — OSRM API + رسم Polyline على الخريطة.
5. **Map Tiles (URL)** — TileLayer من روابط tile servers.
6. **Marker Icons from URL** — أيقونات محمّلة من صور على الإنترنت مع fallback.
7. **Calculate Distance** — المسافة الحقيقية للطريق (km / m).
8. **Estimated Time** — الزمن المتوقع من رد OSRM.
9. **Map Type / Layers** — Standard / Humanitarian / Topographic / Satellite.
10. **Handle Errors & States** — صلاحيات مرفوضة، مفيش إنترنت، مفيش نتائج، loading states.

## Packages
`flutter_map` · `latlong2` · `geolocator` · `http` — بدون أي API keys.

## Project Structure
```
lib/
├── main.dart
├── core/map_styles.dart
├── models/{place.dart, route_info.dart}
├── services/{location_service.dart, geocoding_service.dart, routing_service.dart}
├── widgets/{search_field.dart, route_info_card.dart, url_marker_icon.dart}
└── screens/map_screen.dart
```

## Run
```bash
flutter pub get
flutter run
```
الصلاحيات المطلوبة موجودة في [PERMISSIONS.md](PERMISSIONS.md).
مشاكل تحديد الموقع وحلولها في [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## APIs
- Geocoding: https://nominatim.openstreetmap.org/search
- Routing: https://router.project-osrm.org/route/v1/driving
- Tiles: https://tile.openstreetmap.org

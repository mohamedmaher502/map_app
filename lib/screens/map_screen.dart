import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/map_styles.dart';
import '../models/place.dart';
import '../models/route_info.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';
import '../widgets/route_info_card.dart';
import '../widgets/search_field.dart';
import '../widgets/url_marker_icon.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LatLng? _currentLocation; // بند 01
  Place? _destination; // بند 02
  RouteInfo? _route; // بند 04

  MapStyle _style = MapStyles.standard; // بند 05 + 09

  bool _loadingLocation = false;
  bool _searching = false;
  bool _loadingRoute = false;
  String? _errorMessage; // بند 10

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------- بند 01: Get Current Location ----------------
  Future<void> _initLocation({bool moveCamera = true}) async {
    setState(() {
      _loadingLocation = true;
      _errorMessage = null;
    });

    try {
      final location = await LocationService.getCurrentLocation();
      if (!mounted) return;
      setState(() => _currentLocation = location);
      if (moveCamera) _mapController.move(location, 14);
    } on LocationFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('حدث خطأ غير متوقع أثناء تحديد الموقع.');
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  // ---------------- بند 02: Search for a Location ----------------
  Future<void> _searchPlace() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _searching = true;
      _errorMessage = null;
    });

    try {
      final results = await GeocodingService.search(_searchController.text);
      if (!mounted) return;

      final Place? selected = results.length == 1
          ? results.first
          : await _pickFromResults(results);

      if (selected == null) return;

      setState(() {
        _destination = selected;
        _route = null; // مسار قديم يتشال
      });
      _mapController.move(selected.latLng, 13);
    } on GeocodingFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('فشل البحث. جرّب تاني.');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  /// اختيار نتيجة من عدة نتائج
  Future<Place?> _pickFromResults(List<Place> results) {
    return showModalBottomSheet<Place>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final p = results[i];
            return ListTile(
              leading: const Icon(Icons.place, color: Colors.red),
              title: Text(p.displayName, maxLines: 2),
              subtitle: Text(
                '${p.lat.toStringAsFixed(4)}, ${p.lon.toStringAsFixed(4)}',
              ),
              onTap: () => Navigator.pop(context, p),
            );
          },
        ),
      ),
    );
  }

  // ---------------- بند 04 + 07 + 08: Route + Distance + Duration ----------
  Future<void> _getRoute() async {
    if (_currentLocation == null) {
      await _initLocation(moveCamera: false);
      if (_currentLocation == null) return;
    }
    if (_destination == null) {
      _showError('ابحث عن مكان أولًا.');
      return;
    }

    setState(() {
      _loadingRoute = true;
      _errorMessage = null;
    });

    try {
      final route = await RoutingService.getRoute(
        from: _currentLocation!,
        to: _destination!.latLng,
      );
      if (!mounted) return;
      setState(() => _route = route);
      _fitRoute(route.points);
    } on RoutingFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('فشل جلب المسار من OSRM.');
    } finally {
      if (mounted) setState(() => _loadingRoute = false);
    }
  }

  void _fitRoute(List<LatLng> points) {
    if (points.isEmpty) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(40, 120, 40, 260),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _destination = null;
      _route = null;
      _errorMessage = null;
      _searchController.clear();
    });
    if (_currentLocation != null) _mapController.move(_currentLocation!, 14);
  }

  // ---------------- بند 10: Handle Errors & States ----------------
  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textDirection: TextDirection.rtl),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'إخفاء',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text('Map Route Planner'),
        centerTitle: true,
        actions: [
          // بند 09: تبديل نوع الخريطة
          PopupMenuButton<MapStyle>(
            icon: const Icon(Icons.layers),
            tooltip: 'Map type',
            onSelected: (s) => setState(() => _style = s),
            itemBuilder: (_) => MapStyles.all
                .map(
                  (s) => PopupMenuItem<MapStyle>(
                    value: s,
                    child: Row(
                      children: [
                        Icon(
                          s.name == _style.name
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 18,
                          color: const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 8),
                        Text(s.name),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchBar(),
          if (_errorMessage != null && _destination == null) _buildErrorBanner(),
          if (_destination != null) _buildBottomCard(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'my_location',
            backgroundColor: Colors.white,
            onPressed: _loadingLocation ? null : () => _initLocation(),
            child: _loadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation ?? const LatLng(30.0444, 31.2357),
        initialZoom: 12,
        minZoom: 2,
        maxZoom: 18,
        onTap: (_, __) => FocusScope.of(context).unfocus(),
      ),
      children: [
        // بند 05: Map Tiles من URL
        TileLayer(
          urlTemplate: _style.urlTemplate,
          subdomains: _style.subdomains,
          userAgentPackageName: 'com.example.map_route_planner',
          maxZoom: 18,
        ),

        // بند 04: رسم المسار الحقيقي
        if (_route != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _route!.points,
                strokeWidth: 5,
                color: const Color(0xFF1565C0),
                borderStrokeWidth: 2,
                borderColor: Colors.white,
              ),
            ],
          ),

        // بند 03 + 06: الماركرز بأيقونات من URLs
        MarkerLayer(
          markers: [
            if (_currentLocation != null)
              Marker(
                point: _currentLocation!,
                width: 60,
                height: 62,
                alignment: Alignment.topCenter,
                child: const UrlMarkerIcon(
                  url: MarkerIcons.currentLocation,
                  fallbackIcon: Icons.my_location,
                  fallbackColor: Colors.blue,
                  label: 'You',
                ),
              ),
            if (_destination != null)
              Marker(
                point: _destination!.latLng,
                width: 70,
                height: 62,
                alignment: Alignment.topCenter,
                child: const UrlMarkerIcon(
                  url: MarkerIcons.destination,
                  fallbackIcon: Icons.location_on,
                  fallbackColor: Colors.red,
                  label: 'Target',
                ),
              ),
          ],
        ),

        // حقوق الخريطة (مطلوب مع OpenStreetMap)
        Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            color: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Text(
              _style.attribution,
              style: const TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: SearchField(
        controller: _searchController,
        formKey: _formKey,
        isLoading: _searching,
        onSubmit: _searchPlace,
        onClear: _clearAll,
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Positioned(
      top: 84,
      left: 12,
      right: 12,
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage!,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _errorMessage = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: RouteInfoCard(
        destination: _destination!,
        route: _route,
        isLoading: _loadingRoute,
        onGetRoute: _getRoute,
        onClear: _clearAll,
      ),
    );
  }
}

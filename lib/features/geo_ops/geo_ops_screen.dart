import 'dart:math';
import 'package:admin_dashboard/data/models/delivery_partner.dart';
import 'package:admin_dashboard/data/models/order.dart';
import 'package:admin_dashboard/data/models/restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/dispatch_provider.dart';
import '../../providers/rider_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/geo_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../data/models/zone.dart';

class GeoOpsScreen extends ConsumerStatefulWidget {
  const GeoOpsScreen({super.key});

  @override
  ConsumerState<GeoOpsScreen> createState() => _GeoOpsScreenState();
}

class _GeoOpsScreenState extends ConsumerState<GeoOpsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String? _selectedZoneId;
  String? _selectedMarkerType;
  Map<String, dynamic>? _selectedMarkerData;
  final bool _useGoogleMapWidget =
      true; // Toggle for mock map vs real GoogleMap placeholder

  // Virtual map coordinates and zoom
  double _mapCenterX = 0.5;
  double _mapCenterY = 0.5;
  double _mapZoom = 1.0;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Set<Marker> _buildMapMarkers() {
    final geoState = ref.watch(geoProvider);
    final layerVisibility = geoState.layerVisibility;
    final riders = ref.watch(riderProvider);
    final restaurants = ref.watch(restaurantProvider);
    final orders = ref.watch(orderProvider);

    final Set<Marker> markers = {};

    // Riders
    if (layerVisibility['riders'] == true) {
      for (final rider in riders) {
        markers.add(
          Marker(
            markerId: MarkerId('rider_${rider.id}'),
            position: LatLng(rider.latitude, rider.longitude),
            infoWindow: InfoWindow(
              title: rider.name,
              snippet: 'Status: ${rider.status}',
              onTap: () {
                setState(() {
                  _selectedMarkerData = {
                    'name': rider.name,
                    'description': 'Status: ${rider.status}',
                    'type': 'rider',
                  };
                });
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              rider.status == RiderStatus.available
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    }

    // Restaurants
    if (layerVisibility['restaurants'] == true) {
      for (final rest in ref.watch(restaurantProvider)) {
        markers.add(
          Marker(
            markerId: MarkerId('rest_${rest.id}'),
            position: LatLng(rest.latitude, rest.longitude),
            infoWindow: InfoWindow(
              title: rest.name,
              snippet: 'Status: ${rest.status}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              rest.status == RestaurantStatus.active
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    }

    return markers;
  }

  Set<Polygon> _buildZonePolygons() {
    final dispatchState = ref.watch(dispatchProvider);
    final layerVisibility = ref.watch(geoProvider).layerVisibility;

    if (layerVisibility['zones'] != true) return {};

    final Set<Polygon> polygons = {};

    for (final zone in dispatchState.zones) {
      Color zoneColor = Colors.green;
      if (zone.demandSupplyRatio > 1.5) {
        zoneColor = Colors.red;
      } else if (zone.demandSupplyRatio > 1.2) {
        zoneColor = Colors.orange;
      } else if (zone.demandSupplyRatio < 0.5) {
        zoneColor = Colors.blue;
      }

      polygons.add(
        Polygon(
          polygonId: PolygonId(zone.id),
          points: zone.coordinates
              .map((c) => LatLng(c.latitude, c.longitude))
              .toList(),
          fillColor: zoneColor.withOpacity(0.15),
          strokeColor: zoneColor.withOpacity(0.7),
          strokeWidth: 2,
          onTap: () {
            _focusZone(zone);
          },
        ),
      );
    }

    return polygons;
  }

  Set<Circle> _buildHeatCircles() {
    final dispatchState = ref.watch(dispatchProvider);
    final layerVisibility = ref.watch(geoProvider).layerVisibility;
    final Set<Circle> circles = {};

    for (final zone in dispatchState.zones) {
      if (layerVisibility['demandHeat'] == true) {
        circles.add(
          Circle(
            circleId: CircleId('demand_${zone.id}'),
            center: LatLng(zone.centerLat, zone.centerLng),
            radius: zone.activeOrders * 800.0, // Adjust scale for meters
            fillColor: Colors.red.withOpacity(0.1),
            strokeColor: Colors.red.withOpacity(0.4),
            strokeWidth: 2,
          ),
        );
      }

      if (layerVisibility['supplyHeat'] == true) {
        circles.add(
          Circle(
            circleId: CircleId('supply_${zone.id}'),
            center: LatLng(zone.centerLat, zone.centerLng),
            radius: zone.availableRiders * 1000.0,
            fillColor: Colors.green.withOpacity(0.1),
            strokeColor: Colors.green.withOpacity(0.4),
          ),
        );
      }
    }

    return circles;
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
        // Center on Bengaluru by default
        _mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            const CameraPosition(target: LatLng(12.9716, 77.5946), zoom: 12),
          ),
        );
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(12.9716, 77.5946),
        zoom: 12,
      ),
      markers: _buildMapMarkers(),
      polygons: _buildZonePolygons(),
      circles: _buildHeatCircles(),
      onCameraMoveStarted: () {
        setState(() => _selectedMarkerData = null);
      },
      // litMode: false,
      liteModeEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false, // Use your custom controls
    );
  }

  void _zoomIn() {
    setState(() {
      _mapZoom = min(_mapZoom + 0.2, 2.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _mapZoom = max(_mapZoom - 0.2, 0.6);
      if (_mapZoom < 1.0) {
        _mapCenterX = 0.5;
        _mapCenterY = 0.5;
      }
    });
  }

  void _focusZone(Zone zone) {
    setState(() {
      _selectedZoneId = zone.id;
      _mapZoom = 1.4;
      // Translate lat/lng to normal 0-1 canvas space roughly centered around Bengaluru coordinates
      // Lat 12.8 to 13.0, Lng 77.5 to 77.8
      _mapCenterX = (zone.centerLng - 77.5) / 0.3;
      _mapCenterY = 1.0 - ((zone.centerLat - 12.8) / 0.2);
      _selectedMarkerData = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dispatchState = ref.watch(dispatchProvider);
    final riders = ref.watch(riderProvider);
    final restaurants = ref.watch(restaurantProvider);
    final orders = ref.watch(orderProvider);
    final geoState = ref.watch(geoProvider);
    final layerVisibility = geoState.layerVisibility;

    // Filter elements based on layer toggles
    final availableRiders = riders
        .where((r) => r.status == RiderStatus.available)
        .toList();
    final deliveringRiders = riders
        .where((r) => r.status == RiderStatus.delivering)
        .toList();
    final onlineRestaurants = restaurants
        .where((r) => r.status == RestaurantStatus.active)
        .toList();
    final issuesRestaurants = restaurants
        .where(
          (r) =>
              r.status == RestaurantStatus.suspended ||
              r.status == RestaurantStatus.pendingOnboarding,
        )
        .toList();
    final deliveringOrders = orders
        .where((o) => o.status == OrderStatus.onTheWay)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Area
          _useGoogleMapWidget
              ? _buildGoogleMap()
              : Positioned.fill(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        _mapCenterX -= details.delta.dx / (500 * _mapZoom);
                        _mapCenterY -= details.delta.dy / (500 * _mapZoom);
                        _mapCenterX = _mapCenterX.clamp(-0.5, 1.5);
                        _mapCenterY = _mapCenterY.clamp(-0.5, 1.5);
                      });
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: VectorMapPainter(
                            zones: dispatchState.zones,
                            availableRiders: layerVisibility['riders'] == true
                                ? availableRiders
                                : [],
                            deliveringRiders: layerVisibility['riders'] == true
                                ? deliveringRiders
                                : [],
                            onlineRestaurants:
                                layerVisibility['restaurants'] == true
                                ? onlineRestaurants
                                : [],
                            issuesRestaurants:
                                layerVisibility['restaurants'] == true
                                ? issuesRestaurants
                                : [],
                            deliveringOrders: layerVisibility['orders'] == true
                                ? deliveringOrders
                                : [],
                            layerVisibility: layerVisibility,
                            selectedZoneId: _selectedZoneId,
                            pulseValue: _pulseController.value,
                            centerX: _mapCenterX,
                            centerY: _mapCenterY,
                            zoom: _mapZoom,
                            onTapMarker: (type, data) {
                              setState(() {
                                _selectedMarkerType = type;
                                _selectedMarkerData = data;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

          // Grid Gridlines simulation for high-end UI look
          Positioned.fill(
            child: IgnorePointer(
              child: Opacity(
                opacity: theme.brightness == Brightness.dark ? 0.03 : 0.06,
                child: GridPaper(
                  color: theme.colorScheme.onSurface,
                  divisions: 2,
                  subdivisions: 4,
                  interval: 100,
                ),
              ),
            ),
          ),

          // 2. Zone Health Overlay (Left side 330px on desktop, floating button with bottom sheet on mobile)
          if (context.isCompact)
            Positioned(
              left: 16,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'zone_health_fab',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: theme.colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (ctx) => Container(
                      padding: const EdgeInsets.all(16),
                      height: 400,
                      child: _buildZoneHealthInfo(ctx, true),
                    ),
                  );
                },
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.list_alt_rounded),
              ),
            )
          else
            Positioned(
              left: 16,
              top: 16,
              bottom: 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.colorScheme.surface.withOpacity(0.92),
                child: Container(
                  width: 330,
                  padding: const EdgeInsets.all(16),
                  child: _buildZoneHealthInfo(context, false),
                ),
              ),
            ),

          // 3. Layer Toggle Bar (Top Overlays - scrollable row on mobile, positioned beside the card on desktop)
          Positioned(
            left: context.isCompact ? 16 : 362,
            right: 16,
            top: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildLayerChip(
                    'Zones',
                    'zones',
                    Icons.map_outlined,
                    layerVisibility,
                    ref,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerChip(
                    'Riders',
                    'riders',
                    Icons.delivery_dining_outlined,
                    layerVisibility,
                    ref,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerChip(
                    'Restaurants',
                    'restaurants',
                    Icons.store_outlined,
                    layerVisibility,
                    ref,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerChip(
                    'Orders',
                    'orders',
                    Icons.shopping_bag_outlined,
                    layerVisibility,
                    ref,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerChip(
                    'Demand Heat',
                    'demandHeat',
                    Icons.local_fire_department,
                    layerVisibility,
                    ref,
                  ),
                  const SizedBox(width: 8),
                  _buildLayerChip(
                    'Supply Heat',
                    'supplyHeat',
                    Icons.ac_unit,
                    layerVisibility,
                    ref,
                  ),
                ],
              ),
            ),
          ),

          // 4. Map Zoom and Control Buttons (Bottom Right overlay)
          Positioned(
            right: 16,
            bottom: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  onPressed: _zoomIn,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  onPressed: _zoomOut,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'reset_view',
                  onPressed: () {
                    setState(() {
                      _mapCenterX = 0.5;
                      _mapCenterY = 0.5;
                      _mapZoom = 1.0;
                      _selectedZoneId = null;
                      _selectedMarkerData = null;
                    });
                  },
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.onSurface,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),

          // 5. Selected Marker Details Dialog Panel (Bottom-Left overlay on desktop, center-bottom on mobile)
          if (_selectedMarkerData != null)
            Positioned(
              left: context.isCompact ? 16 : 362,
              right: context.isCompact ? 16 : 80,
              bottom: context.isCompact ? 80 : 16,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.colorScheme.surface.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _selectedMarkerType == 'restaurant'
                            ? kSeedColor.withOpacity(0.1)
                            : kInfo.withOpacity(0.1),
                        child: Icon(
                          _selectedMarkerType == 'restaurant'
                              ? Icons.store
                              : _selectedMarkerType == 'rider'
                              ? Icons.delivery_dining
                              : Icons.shopping_bag,
                          color: _selectedMarkerType == 'restaurant'
                              ? kSeedColor
                              : kInfo,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMarkerData!['name'] ?? 'Detail Info',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedMarkerData!['description'] ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedMarkerData = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildZoneHealthInfo(BuildContext context, bool isBottomSheet) {
    final theme = Theme.of(context);
    final dispatchState = ref.watch(dispatchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: kSeedColor),
            const SizedBox(width: 8),
            Text(
              'Zone Health Info',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isBottomSheet) ...[
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: dispatchState.zones.length,
            separatorBuilder: (_, __) => const Divider(height: 12),
            itemBuilder: (context, index) {
              final zone = dispatchState.zones[index];
              final isSelected = zone.id == _selectedZoneId;

              // Color based on Demand-Supply ratio
              Color ratioColor = kSuccess;
              if (zone.demandSupplyRatio > 1.5) {
                ratioColor = kDanger;
              } else if (zone.demandSupplyRatio > 1.2) {
                ratioColor = kWarning;
              } else if (zone.demandSupplyRatio < 0.5) {
                ratioColor = kInfo;
              }

              return InkWell(
                onTap: () {
                  _focusZone(zone);
                  if (isBottomSheet) {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer.withOpacity(0.4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                          )
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            zone.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ratioColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'D/S ${zone.demandSupplyRatio.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ratioColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildZoneStat(
                            Icons.shopping_bag_outlined,
                            '${zone.activeOrders} Orders',
                            theme,
                          ),
                          const SizedBox(width: 12),
                          _buildZoneStat(
                            Icons.delivery_dining_outlined,
                            '${zone.availableRiders} Riders',
                            theme,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Surge Pricing',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 24,
                            child: Switch(
                              value: zone.isSurgeActive,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                ref
                                    .read(dispatchProvider.notifier)
                                    .toggleSurge(zone.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildZoneStat(IconData icon, String text, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildLayerChip(
    String label,
    String key,
    IconData icon,
    Map<String, bool> layerVisibility,
    WidgetRef ref,
  ) {
    final active = layerVisibility[key] == true;
    final theme = Theme.of(ref.context);

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: active ? Colors.white : theme.colorScheme.onSurfaceVariant,
      ),
      label: Text(label),
      selected: active,
      checkmarkColor: Colors.white,
      selectedColor: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: active ? Colors.white : theme.colorScheme.onSurface,
      ),
      onSelected: (val) {
        ref.read(geoProvider.notifier).toggleLayer(key);
      },
    );
  }
}

// Custom painter to draw the stylized interactive vector map
class VectorMapPainter extends CustomPainter {
  final List<Zone> zones;
  final List<dynamic> availableRiders;
  final List<dynamic> deliveringRiders;
  final List<dynamic> onlineRestaurants;
  final List<dynamic> issuesRestaurants;
  final List<dynamic> deliveringOrders;
  final Map<String, bool> layerVisibility;
  final String? selectedZoneId;
  final double pulseValue;
  final double centerX;
  final double centerY;
  final double zoom;
  final Function(String type, Map<String, dynamic> data) onTapMarker;

  VectorMapPainter({
    required this.zones,
    required this.availableRiders,
    required this.deliveringRiders,
    required this.onlineRestaurants,
    required this.issuesRestaurants,
    required this.deliveringOrders,
    required this.layerVisibility,
    required this.selectedZoneId,
    required this.pulseValue,
    required this.centerX,
    required this.centerY,
    required this.zoom,
    required this.onTapMarker,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Apply zoom and translate camera transformations
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(zoom);
    canvas.translate(-centerX * size.width, -centerY * size.height);

    // Draw grid background paths (Bengaluru simulated waterways/rivers & roads)
    final riverPaint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.1)
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPaint = Paint()
      ..color = const Color(0xFFB0BEC5).withOpacity(0.08)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final roadPaintBold = Paint()
      ..color = const Color(0xFFB0BEC5).withOpacity(0.12)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    // Simulate drawing some geographical landmarks
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.4),
      riverPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
      roadPaintBold,
    );
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.5),
      roadPaintBold,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, size.height * 0.1),
      Offset(size.width * 0.7, size.height * 0.9),
      roadPaint,
    );

    // Coordinate translator helper
    Offset translateCoords(double lat, double lng) {
      // Lat 12.8 to 13.0, Lng 77.5 to 77.8
      final x = ((lng - 77.5) / 0.3) * size.width;
      final y = (1.0 - ((lat - 12.8) / 0.2)) * size.height;
      return Offset(x, y);
    }

    Offset getEntityPos(dynamic entity) {
      final r = Random(entity.id.hashCode);
      final lat = 12.91 + r.nextDouble() * 0.08;
      final lng = 77.58 + r.nextDouble() * 0.12;
      return translateCoords(lat, lng);
    }

    // Draw demand/supply heat rings if enabled
    if (layerVisibility['demandHeat'] == true ||
        layerVisibility['supplyHeat'] == true) {
      for (final zone in zones) {
        final centerOffset = translateCoords(zone.centerLat, zone.centerLng);
        if (layerVisibility['demandHeat'] == true) {
          final heatPaint = Paint()
            ..color = kDanger.withOpacity(0.25 + 0.1 * sin(pulseValue * 2 * pi))
            ..style = PaintingStyle.fill;
          canvas.drawCircle(centerOffset, zone.activeOrders * 12.0, heatPaint);
        }
        if (layerVisibility['supplyHeat'] == true) {
          final heatPaint = Paint()
            ..color = kSuccess.withOpacity(0.2 + 0.1 * cos(pulseValue * 2 * pi))
            ..style = PaintingStyle.fill;
          canvas.drawCircle(
            centerOffset,
            zone.availableRiders * 14.0,
            heatPaint,
          );
        }
      }
    }

    // 1. Draw Zone Polygons
    if (layerVisibility['zones'] == true) {
      for (final zone in zones) {
        final centerOffset = translateCoords(zone.centerLat, zone.centerLng);
        final ratio = zone.demandSupplyRatio;
        final isSelected = zone.id == selectedZoneId;

        Color zoneColor = kSuccess;
        if (ratio > 1.5) {
          zoneColor = kDanger;
        } else if (ratio > 1.2) {
          zoneColor = kWarning;
        } else if (ratio < 0.5) {
          zoneColor = kInfo;
        }

        // Draw hexagon or circle approximation for the zone polygon
        final path = Path();
        final radius = 95.0;
        final points = 6;
        for (int i = 0; i < points; i++) {
          final angle = (i * 2 * pi) / points;
          final px = centerOffset.dx + radius * cos(angle);
          final py = centerOffset.dy + radius * sin(angle);
          if (i == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();

        // Fill paint
        final fillPaint = Paint()
          ..color = zoneColor.withOpacity(isSelected ? 0.3 : 0.12)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        // Border paint
        final borderPaint = Paint()
          ..color = zoneColor.withOpacity(isSelected ? 0.8 : 0.4)
          ..strokeWidth = isSelected ? 3.0 : 1.5
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, borderPaint);

        // Draw label text
        final textPainter = TextPainter(
          text: TextSpan(
            text:
                '${zone.name}\nDS: ${zone.demandSupplyRatio.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? zoneColor : Colors.grey[600],
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(
            centerOffset.dx - textPainter.width / 2,
            centerOffset.dy - textPainter.height / 2,
          ),
        );
      }
    }

    // 2. Draw Online & Suspended/Pending Restaurants
    final storePaint = Paint()
      ..color = kSeedColor
      ..style = PaintingStyle.fill;

    for (final rest in onlineRestaurants) {
      final pos = getEntityPos(rest);
      // Main shop marker dot
      canvas.drawCircle(pos, 8, storePaint);
      canvas.drawCircle(
        pos,
        8 + 6 * pulseValue,
        Paint()
          ..color = kSeedColor.withOpacity(0.2 - 0.2 * pulseValue)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Inner white dot
      canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
    }

    final alertStorePaint = Paint()
      ..color = kDanger
      ..style = PaintingStyle.fill;

    for (final rest in issuesRestaurants) {
      final pos = getEntityPos(rest);
      canvas.drawCircle(pos, 8, alertStorePaint);
      canvas.drawCircle(pos, 3, Paint()..color = Colors.white);
    }

    // 3. Draw Riders (Green = Available, Blue = Delivering)
    final avRiderPaint = Paint()
      ..color = kSuccess
      ..style = PaintingStyle.fill;

    for (final rider in availableRiders) {
      final pos = getEntityPos(rider);
      canvas.drawCircle(pos, 6, avRiderPaint);
      canvas.drawCircle(
        pos,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    final delRiderPaint = Paint()
      ..color = kInfo
      ..style = PaintingStyle.fill;

    for (final rider in deliveringRiders) {
      final pos = getEntityPos(rider);
      canvas.drawCircle(pos, 6, delRiderPaint);
    }

    // 4. Draw Delivering Orders (Packages)
    final pkgPaint = Paint()
      ..color = const Color(0xFF9C27B0)
      ..style = PaintingStyle.fill;

    for (final order in deliveringOrders) {
      final pos = getEntityPos(order);
      canvas.drawRect(
        Rect.fromCenter(center: pos, width: 8, height: 8),
        pkgPaint,
      );
    }

    // Restore canvas modifications
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant VectorMapPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.zoom != zoom ||
        oldDelegate.centerX != centerX ||
        oldDelegate.centerY != centerY ||
        oldDelegate.selectedZoneId != selectedZoneId ||
        oldDelegate.availableRiders.length != availableRiders.length ||
        oldDelegate.onlineRestaurants.length != onlineRestaurants.length;
  }
}

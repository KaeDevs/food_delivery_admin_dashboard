import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/delivery_partner.dart';
import '../../../providers/rider_provider.dart';

class LiveFleetStatusCard extends ConsumerStatefulWidget {
  const LiveFleetStatusCard({super.key});

  @override
  ConsumerState<LiveFleetStatusCard> createState() => _LiveFleetStatusCardState();
}

class _LiveFleetStatusCardState extends ConsumerState<LiveFleetStatusCard> {
  GoogleMapController? _mapController;
  double _currentZoom = 11.0;
  final LatLng _currentTarget = const LatLng(12.9716, 77.5946);
  bool _isHovered = false;

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(3.0, 20.0);
    });
    _mapController?.animateCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(3.0, 20.0);
    });
    _mapController?.animateCamera(
      CameraUpdate.zoomTo(_currentZoom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riders = ref.watch(riderProvider);

    final inMotion = riders
        .where((r) => r.status == RiderStatus.delivering || r.status == RiderStatus.assigned)
        .length;
    final idle = riders
        .where((r) => r.status == RiderStatus.available)
        .length;

    // Convert riders to Markers
    final markers = riders
        .where((r) => r.status != RiderStatus.offline && r.status != RiderStatus.suspended)
        .map((rider) {
      return Marker(
        markerId: MarkerId('live_fleet_${rider.id}'),
        position: LatLng(rider.latitude, rider.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          rider.status == RiderStatus.available
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueBlue,
        ),
      );
    }).toSet();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          elevation: _isHovered ? 6 : 0,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.08),
          child: InkWell(
            onTap: () => context.go('/geo-ops'),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? theme.colorScheme.primary.withOpacity(0.4)
                      : theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LIVE FLEET STATUS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _PulsingDot(),
                            const SizedBox(width: 6),
                            Text(
                              'Live',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: kSuccess,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Map Area
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _currentTarget,
                                zoom: _currentZoom,
                              ),
                              markers: markers,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                              mapToolbarEnabled: false,
                              compassEnabled: false,
                              onMapCreated: (controller) {
                                _mapController = controller;
                              },
                            ),
                          ),
                        ),

                        // Zoom Controls
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.zero,
                            color: theme.colorScheme.surface,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: _zoomIn,
                                    tooltip: 'Zoom In',
                                  ),
                                  Container(
                                    width: 16,
                                    height: 1,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: _zoomOut,
                                    tooltip: 'Zoom Out',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Metrics Footer
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$inMotion',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF00796B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'In Motion',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$idle',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Idle',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kSuccess.withOpacity(0.3 + 0.7 * _controller.value),
            boxShadow: [
              BoxShadow(
                color: kSuccess.withOpacity(0.4 * _controller.value),
                blurRadius: 4,
                spreadRadius: 2 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}

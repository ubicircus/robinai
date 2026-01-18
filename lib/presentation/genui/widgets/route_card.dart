import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteCard extends StatelessWidget {
  final String? title;
  final String distanceText;
  final String durationText;
  final String? mode;
  final String? polyline; // Encoded polyline string
  final Map<String, dynamic>? origin; // {address: "..."} or {latitude: ..., longitude: ...}
  final Map<String, dynamic>? destination; // Same format

  const RouteCard({
    super.key,
    this.title,
    required this.distanceText,
    required this.durationText,
    this.mode,
    this.polyline,
    this.origin,
    this.destination,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title?.trim().isNotEmpty == true ? title! : 'Route';
    final modeLabel = _formatMode(mode);
    final hasMap = polyline != null && polyline!.isNotEmpty;
    final hasCoordinates = origin != null && destination != null;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
                if (modeLabel != null)
                  Text(
                    modeLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
              ],
            ),
            const Divider(),
            Text(
              'Duration: $durationText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Distance: $distanceText',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (hasMap) ...[
              const SizedBox(height: 12),
              _buildMapPreview(context),
            ],
            if (hasCoordinates || hasMap) ...[
              const SizedBox(height: 12),
              _buildMapButtons(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview(BuildContext context) {
    try {
      final points = _decodePolyline(polyline!);
      if (points.isEmpty) return const SizedBox.shrink();

      // Calculate bounds
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;

      for (final point in points) {
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
      }

      final center = LatLng(
        (minLat + maxLat) / 2,
        (minLng + maxLng) / 2,
      );

      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: _calculateZoom(minLat, maxLat, minLng, maxLng),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.robinai.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 4.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (points.isNotEmpty)
                    Marker(
                      point: points.first,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                  if (points.length > 1)
                    Marker(
                      point: points.last,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 32,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildMapButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildClickableGraphic(
            context: context,
            onTap: () => _openGoogleMaps(),
            icon: Icons.map,
            label: 'Google Maps',
            backgroundColor: const Color(0xFF4285F4),
            iconColor: Colors.white,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildClickableGraphic(
            context: context,
            onTap: () => _openAppleMaps(),
            icon: Icons.map_outlined,
            label: 'Maps',
            backgroundColor: Colors.white,
            iconColor: Theme.of(context).colorScheme.onSurface,
            textColor: Theme.of(context).colorScheme.onSurface,
            hasBorder: true,
          ),
        ),
      ],
    );
  }

  Widget _buildClickableGraphic({
    required BuildContext context,
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    bool hasBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: hasBorder
              ? Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  double _calculateZoom(double minLat, double maxLat, double minLng, double maxLng) {
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    if (maxDiff > 1.0) return 6.0;
    if (maxDiff > 0.5) return 7.0;
    if (maxDiff > 0.25) return 8.0;
    if (maxDiff > 0.1) return 9.0;
    if (maxDiff > 0.05) return 10.0;
    if (maxDiff > 0.025) return 11.0;
    return 12.0;
  }

  String? _formatMode(String? mode) {
    if (mode == null || mode.isEmpty) return null;
    switch (mode) {
      case 'walk':
        return 'Walk';
      case 'drive':
        return 'Drive';
      case 'transit':
        return 'Transit';
      case 'bicycle':
        return 'Bike';
      default:
        return mode;
    }
  }

  Future<void> _openGoogleMaps() async {
    String? originStr = _formatLocation(origin);
    String? destStr = _formatLocation(destination);

    if (originStr == null || destStr == null) return;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/${Uri.encodeComponent(originStr)}/${Uri.encodeComponent(destStr)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _openAppleMaps() async {
    String? originStr = _formatLocation(origin);
    String? destStr = _formatLocation(destination);

    if (originStr == null || destStr == null) return;

    final url = Uri.parse(
      'https://maps.apple.com/?daddr=${Uri.encodeComponent(destStr)}&saddr=${Uri.encodeComponent(originStr)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String? _formatLocation(Map<String, dynamic>? location) {
    if (location == null) return null;

    // Check for address first
    if (location.containsKey('address')) {
      return location['address']?.toString();
    }

    // Check for coordinates
    if (location.containsKey('latitude') && location.containsKey('longitude')) {
      final lat = location['latitude'];
      final lng = location['longitude'];
      return '$lat,$lng';
    }

    // Check for place_id
    if (location.containsKey('place_id')) {
      return location['place_id']?.toString();
    }

    return null;
  }
}

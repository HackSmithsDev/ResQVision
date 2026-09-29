import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _missionCentre = LatLng(30.7276, 78.4386);

class RescueOsmMap extends StatelessWidget {
  const RescueOsmMap({super.key, this.onDroneTap});

  final VoidCallback? onDroneTap;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _missionCentre,
        initialZoom: 14.8,
        maxZoom: 19,
        keepAlive: true,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          cursorKeyboardRotationOptions:
              CursorKeyboardRotationOptions.disabled(),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.rescuevision',
          maxZoom: 19,
        ),
        PolygonLayer(
          polygons: [
            Polygon(
              points: const [
                LatLng(30.7335, 78.4305),
                LatLng(30.7351, 78.4380),
                LatLng(30.7306, 78.4404),
                LatLng(30.7289, 78.4341),
              ],
              color: const Color(0x66E84142),
              borderColor: const Color(0xFFE84142),
              borderStrokeWidth: 3,
            ),
          ],
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: const [
                LatLng(30.7216, 78.4360),
                LatLng(30.7242, 78.4390),
                LatLng(30.7276, 78.4386),
                LatLng(30.7294, 78.4410),
                LatLng(30.7258, 78.4444),
              ],
              color: const Color(0xFF2E80FF),
              strokeWidth: 6,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            _marker(
              point: const LatLng(30.7318, 78.4344),
              color: Colors.red,
              title: 'Landslide Zone',
              subtitle: 'High risk',
            ),
            _marker(
              point: const LatLng(30.7294, 78.4410),
              color: Colors.green,
              title: 'Drone A',
              subtitle: 'Live · battery 74%',
              onTap: onDroneTap,
            ),
            _marker(
              point: const LatLng(30.7258, 78.4444),
              color: Colors.orange,
              title: 'Survivor (2)',
              subtitle: '~ 320 m away',
            ),
            _marker(
              point: const LatLng(30.7216, 78.4360),
              color: Colors.red,
              title: 'Rescue Team',
              subtitle: '~ 1.2 km away',
            ),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }

  Marker _marker({
    required LatLng point,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: point,
      width: 48,
      height: 48,
      alignment: Alignment.bottomCenter,
      child: Tooltip(
        message: '$title\n$subtitle',
        child: GestureDetector(
          onTap: onTap,
          child: Icon(Icons.location_on, color: color, size: 42),
        ),
      ),
    );
  }
}

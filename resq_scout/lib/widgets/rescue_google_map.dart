import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

const _missionCentre = LatLng(30.7276, 78.4386);

class RescueGoogleMap extends StatelessWidget {
  const RescueGoogleMap({super.key, this.onDroneTap});

  final VoidCallback? onDroneTap;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _missionCentre,
        zoom: 14.8,
      ),
      mapType: MapType.hybrid,
      compassEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationButtonEnabled: false,
      markers: {
        Marker(
          markerId: const MarkerId('hazard'),
          position: const LatLng(30.7318, 78.4344),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Landslide Zone',
            snippet: 'High risk',
          ),
        ),
        Marker(
          markerId: const MarkerId('drone-a'),
          position: const LatLng(30.7294, 78.4410),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(
            title: 'Drone A',
            snippet: 'Live · battery 74%',
          ),
          onTap: onDroneTap,
        ),
        Marker(
          markerId: const MarkerId('survivor'),
          position: const LatLng(30.7258, 78.4444),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: const InfoWindow(
            title: 'Survivor (2)',
            snippet: '~ 320 m away',
          ),
        ),
        Marker(
          markerId: const MarkerId('rescue-team'),
          position: const LatLng(30.7216, 78.4360),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: 'Rescue Team',
            snippet: '~ 1.2 km away',
          ),
        ),
      },
      polylines: {
        const Polyline(
          polylineId: PolylineId('mission-route'),
          color: Color(0xFF2E80FF),
          width: 6,
          points: [
            LatLng(30.7216, 78.4360),
            LatLng(30.7242, 78.4390),
            LatLng(30.7276, 78.4386),
            LatLng(30.7294, 78.4410),
            LatLng(30.7258, 78.4444),
          ],
        ),
      },
      polygons: {
        Polygon(
          polygonId: const PolygonId('landslide-zone'),
          points: const [
            LatLng(30.7335, 78.4305),
            LatLng(30.7351, 78.4380),
            LatLng(30.7306, 78.4404),
            LatLng(30.7289, 78.4341),
          ],
          strokeColor: const Color(0xFFE84142),
          strokeWidth: 3,
          fillColor: const Color(0x66E84142),
        ),
      },
    );
  }
}

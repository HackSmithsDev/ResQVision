import 'package:flutter/material.dart';

import '../../config/map_config.dart';
import '../rescue_google_map.dart';
import 'rescue_osm_map.dart';

class RescueMap extends StatelessWidget {
  const RescueMap({super.key, this.onDroneTap});

  final VoidCallback? onDroneTap;

  @override
  Widget build(BuildContext context) {
    if (MapConfig.useGoogleMaps) {
      return RescueGoogleMap(onDroneTap: onDroneTap);
    }

    return RescueOsmMap(onDroneTap: onDroneTap);
  }
}

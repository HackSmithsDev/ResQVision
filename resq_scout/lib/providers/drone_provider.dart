import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_drone_data.dart';
import '../models/drone.dart';

/// The fleet source is centralized so API-backed data can replace the mock
/// without changing drone-related screens.
final droneProvider = Provider<List<Drone>>((ref) => mockDrones);

final droneByIdProvider = Provider.family<Drone?, String>((ref, droneId) {
  for (final drone in ref.watch(droneProvider)) {
    if (drone.id == droneId) return drone;
  }
  return null;
});

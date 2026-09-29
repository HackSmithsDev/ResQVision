enum DroneStatus { active, charging, offline }

/// Transport-friendly drone state. Presentation concerns such as colors and
/// icons intentionally stay in the widget layer so this maps cleanly to a
/// future API response.
class Drone {
  const Drone({
    required this.id,
    required this.name,
    required this.status,
    required this.location,
    required this.batteryPercentage,
    required this.altitudeMeters,
    required this.speedKmh,
    required this.signalDbm,
    required this.lastUpdated,
    required this.videoAvailable,
    this.thumbnailUrl,
  });

  final String id;
  final String name;
  final DroneStatus status;
  final String location;
  final int batteryPercentage;
  final double? altitudeMeters;
  final double? speedKmh;
  final int? signalDbm;
  final DateTime lastUpdated;
  final bool videoAvailable;
  final String? thumbnailUrl;

  bool get isActive => status == DroneStatus.active;

  factory Drone.fromJson(Map<String, dynamic> json) => Drone(
    id: json['id'] as String,
    name: json['name'] as String,
    status: DroneStatus.values.byName(json['status'] as String),
    location: json['location'] as String,
    batteryPercentage: (json['batteryPercentage'] as num).round(),
    altitudeMeters: (json['altitudeMeters'] as num?)?.toDouble(),
    speedKmh: (json['speedKmh'] as num?)?.toDouble(),
    signalDbm: (json['signalDbm'] as num?)?.round(),
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    videoAvailable: json['videoAvailable'] as bool? ?? false,
    thumbnailUrl: json['thumbnailUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.name,
    'location': location,
    'batteryPercentage': batteryPercentage,
    'altitudeMeters': altitudeMeters,
    'speedKmh': speedKmh,
    'signalDbm': signalDbm,
    'lastUpdated': lastUpdated.toIso8601String(),
    'videoAvailable': videoAvailable,
    'thumbnailUrl': thumbnailUrl,
  };
}

class DroneData {
  const DroneData({
    required this.name,
    required this.battery,
    required this.altitude,
    required this.status,
  });

  final String name;
  final int battery;
  final int altitude;
  final String status;
}

const droneA = DroneData(
  name: 'Drone A',
  battery: 74,
  altitude: 82,
  status: 'Live',
);

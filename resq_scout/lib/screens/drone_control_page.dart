import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../models/drone.dart';
import '../providers/drone_provider.dart';
import '../widgets/drone_widgets.dart';

class DroneControlPage extends ConsumerStatefulWidget {
  const DroneControlPage({super.key});

  @override
  ConsumerState<DroneControlPage> createState() => _DroneControlPageState();
}

class _DroneControlPageState extends ConsumerState<DroneControlPage> {
  String _query = '';
  DroneStatus? _filter;
  String? _expandedDroneId;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  List<Drone> _filteredDrones(List<Drone> fleet) {
    final query = _query.trim().toLowerCase();
    return fleet.where((drone) {
      final matchesFilter = _filter == null || drone.status == _filter;
      final matchesQuery =
          query.isEmpty ||
          drone.name.toLowerCase().contains(query) ||
          drone.location.toLowerCase().contains(query) ||
          drone.status.name.contains(query);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  void _openLiveFootage(Drone drone) {
    context.push(AppRoutes.liveFootageFor(drone.id));
  }

  void _openManualControl(Drone drone) {
    context.push(AppRoutes.manualControlFor(drone.id));
  }

  @override
  Widget build(BuildContext context) {
    final fleet = ref.watch(droneProvider);
    final drones = _filteredDrones(fleet);
    final active = drones.where((drone) => drone.isActive).toList();
    final other = drones.where((drone) => !drone.isActive).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drone Control',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF14223B),
                              ),
                            ),
                            Text(
                              'Monitor and manage your drone fleet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Color(0xFF667085)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DroneStatusSummary(drones: fleet),
                  const SizedBox(height: 15),
                  DroneSearchBar(
                    onChanged: (value) => setState(() => _query = value),
                    selectedFilter: _filter,
                    onFilterSelected: (value) =>
                        setState(() => _filter = value),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView(
                      children: [
                        if (active.isNotEmpty) ...[
                          SectionHeader(
                            title: 'Active Drones',
                            count: active.length,
                          ),
                          const SizedBox(height: 10),
                          ...active.map(_buildDroneCard),
                        ],
                        if (other.isNotEmpty) ...[
                          if (active.isNotEmpty) const SizedBox(height: 17),
                          SectionHeader(
                            title: 'Other Drones',
                            count: other.length,
                          ),
                          const SizedBox(height: 10),
                          ...other.map(_buildDroneCard),
                        ],
                        if (drones.isEmpty) const _EmptyDroneResults(),
                        const SizedBox(height: 8),
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

  Widget _buildDroneCard(Drone drone) => Padding(
    padding: const EdgeInsets.only(bottom: 11),
    child: ExpandableDroneCard(
      drone: drone,
      isExpanded: _expandedDroneId == drone.id,
      onToggle: () => setState(() {
        _expandedDroneId = _expandedDroneId == drone.id ? null : drone.id;
      }),
      onLiveFootage: () => _openLiveFootage(drone),
      onManualControl: () => _openManualControl(drone),
    ),
  );
}

class _EmptyDroneResults extends StatelessWidget {
  const _EmptyDroneResults();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 38),
    child: Column(
      children: [
        Icon(Icons.search_off_rounded, size: 42, color: Color(0xFF667085)),
        SizedBox(height: 10),
        Text(
          'No drones match your search',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF14223B),
          ),
        ),
      ],
    ),
  );
}

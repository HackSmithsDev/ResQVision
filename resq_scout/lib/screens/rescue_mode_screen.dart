import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../models/emergency_action.dart';
import '../models/rescue_session.dart';
import '../providers/rescue_session_provider.dart';
import '../widgets/emergency_action_bottom_sheet.dart';
import '../widgets/maps/rescue_map.dart';
import '../widgets/rescue_widgets.dart';

class RescueModeScreen extends ConsumerWidget {
  const RescueModeScreen({super.key});

  void _openEmergencyAction(BuildContext context, EmergencyActionType type) {
    showEmergencyActionBottomSheet(context: context, type: type);
  }

  void _droneDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drone A · Live',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusChip(
                  icon: Icons.battery_5_bar,
                  text: '74% battery',
                  color: Color(0xFF18AE73),
                ),
                StatusChip(
                  icon: Icons.height,
                  text: '82 m',
                  color: Color(0xFF2878E6),
                ),
                StatusChip(
                  icon: Icons.speed,
                  text: '32 km/h',
                  color: Color(0xFFD79416),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Drone A is scanning the active landslide sector. Its position updates automatically in this simulation.',
            ),
          ],
        ),
      ),
    );
  }

  void _supportSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.medical_services,
                color: Color(0xFF2878E6),
              ),
              title: const Text('Request medical unit'),
              onTap: () {
                Navigator.pop(context);
                _openEmergencyAction(context, EmergencyActionType.medical);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bed, color: Color(0xFF20A366)),
              title: const Text('Request stretcher'),
              onTap: () {
                Navigator.pop(context);
                _openEmergencyAction(context, EmergencyActionType.stretcher);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flight, color: Color(0xFFD79416)),
              title: const Text('Call rescue helicopter'),
              onTap: () {
                Navigator.pop(context);
                _openEmergencyAction(context, EmergencyActionType.helicopter);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(rescueSessionProvider);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RescueMap(onDroneTap: () => _droneDetails(context)),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .27),
                ),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 5,
            child: RoundToolButton(
              icon: Icons.close,
              dark: true,
              onTap: () => context.pop(),
            ),
          ),
          Positioned(top: 30, left: 80, child: _topStatus()),
          Positioned(top: 30, right: 5, child: _gps()),
          const Positioned(
            top: 170,
            left: 20,
            child: Column(
              children: [
                // RoundToolButton(icon: Icons.layers, dark: true),
                // SizedBox(height: 10),
                // RoundToolButton(icon: Icons.view_in_ar, dark: true),
                // SizedBox(height: 10),
                // RoundToolButton(icon: Icons.straighten, dark: true),
              ],
            ),
          ),
          const Positioned(
            top: 155,
            right: 20,
            child: Column(
              children: [
                RoundToolButton(icon: Icons.explore, dark: true),
                SizedBox(height: 10),
                RoundToolButton(icon: Icons.my_location, dark: true),
              ],
            ),
          ),
          Positioned(bottom: 100, left: 5, child: _liveFeed(context)),
          Positioned(bottom: 100, right: 3, child: _missionRoute()),
          Positioned(
            bottom: 5,
            left: 0,
            right: 0,
            child: _actions(context, session),
          ),
        ],
      ),
    );
  }

  Widget _topStatus() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    decoration: BoxDecoration(
      color: const Color(0xE9101924),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white24),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: Color(0xFFFF4949), size: 10),
        SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RESCUE MODE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 10,
              ),
            ),
            Text(
              'Live Response Active',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _gps() => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: const Color(0xE9101924),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Colors.white24),
    ),
    child: const Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: Color(0xFF31D58A), size: 10),
            SizedBox(width: 5),
            Text('GPS · Strong', style: TextStyle(color: Color(0xFF76E9AB),fontSize:10)),
          ],
        ),
        Text(
          'Accurate to 3 m',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _liveFeed(BuildContext context) => GestureDetector(
    onTap: () => context.push(AppRoutes.droneControl),
    child: Container(
      width: 140,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xE9101924),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: const SizedBox(
              height: 70,
              width: double.infinity,
              child: ColoredBox(
                color: Color(0xFF111B30),
                child: Center(
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white70,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Text(
                'Ground video unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _missionRoute() => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xE9101924),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.route, color: Color(0xFF4D91FF)),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mission Route',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '2.4 km · ~28 min',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        SizedBox(width: 8),
        Icon(Icons.chevron_right, color: Colors.white),
      ],
    ),
  );

  Widget _actions(BuildContext context, RescueSession session) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _roundAction(
        Icons.location_on,
        'Mark\nLocation',
        const Color(0xFF2878E6),
        () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location marked for team Alpha-02')),
        ),
      ),
      Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _openEmergencyAction(context, EmergencyActionType.sos),
          customBorder: const CircleBorder(),
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF5353), Color(0xFFD91E2A)],
              ),
              boxShadow: [BoxShadow(color: Color(0x99FF2424), blurRadius: 24)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_in_talk, color: Colors.white, size: 37),
                const SizedBox(height: 3),
                Text(
                  session.isRequested(EmergencyActionType.sos)
                      ? 'SOS ACTIVE'
                      : 'SOS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                // Text(
                //   session.isRequested(EmergencyActionType.sos)
                //       ? 'Teams notified'
                //       : 'Tap to open',
                //   style: const TextStyle(color: Colors.white70),
                // ),
              ],
            ),
          ),
        ),
      ),
      _roundAction(
        Icons.groups,
        'Request\nSupport',
        const Color(0xFF2878E6),
        () => _supportSheet(context),
      ),
    ],
  );

  Widget _roundAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) => Material(
    color: const Color(0xE9101924),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                // fontWeight: FontWeight.w800,
                fontSize:10,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

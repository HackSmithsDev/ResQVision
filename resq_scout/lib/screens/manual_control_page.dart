import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../providers/drone_provider.dart';
import '../widgets/drone_widgets.dart';

class ManualControlPage extends ConsumerStatefulWidget {
  const ManualControlPage({super.key, required this.droneId});
  final String droneId;

  @override
  ConsumerState<ManualControlPage> createState() => _ManualControlPageState();
}

class _ManualControlPageState extends ConsumerState<ManualControlPage> {
  String _command = 'Manual controls ready';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Returning exposes the portrait fleet controller underneath.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _setCommand(String command) => setState(() => _command = command);

  @override
  Widget build(BuildContext context) {
    final drone = ref.watch(droneByIdProvider(widget.droneId));
    if (drone == null) {
      return const Scaffold(body: Center(child: Text('Drone not found')));
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DroneVideoView(drone: drone, message: _command),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final joystickSize = (constraints.maxHeight * .25)
                    .clamp(100.0, 180.0)
                    .toDouble();
                return Padding(
                  padding: const EdgeInsets.all(18),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RoundDarkButton(
                              icon: Icons.arrow_back_rounded,
                              tooltip: 'Back',
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xD9111B30),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${drone.name} · Manual control',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: TelemetryBar(drone: drone),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CameraControlButton(
                              icon: Icons.camera_alt_outlined,
                              tooltip: 'Capture image',
                              onPressed: () =>
                                  _setCommand('Photo captured locally'),
                            ),
                            const SizedBox(height: 9),
                            CameraControlButton(
                              icon: Icons.map_outlined,
                              tooltip: 'Open map',
                              onPressed: () => _setCommand('Map view selected'),
                            ),
                            const SizedBox(height: 9),
                            CameraControlButton(
                              icon: Icons.settings_outlined,
                              tooltip: 'Control settings',
                              onPressed: () =>
                                  _setCommand('Control settings selected'),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: SizedBox(
                          width: joystickSize,
                          height: joystickSize,
                          child: VirtualJoystick(
                            label: 'ALT / YAW',
                            icon: Icons.swap_vert_rounded,
                            onChanged: (value) => _setCommand(
                              value == Offset.zero
                                  ? 'Altitude / yaw centered'
                                  : 'Altitude / yaw input',
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Wrap(
                          spacing: 9,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ControlButton(
                              label: 'Land',
                              icon: Icons.flight_land_rounded,
                              color: const Color(0xFFD52C3E),
                              onPressed: () =>
                                  _setCommand('Landing command queued locally'),
                            ),
                            ControlButton(
                              label: 'Stop',
                              icon: Icons.stop_circle_outlined,
                              color: const Color(0xFF2878E6),
                              onPressed: () => _setCommand(
                                'Hold position command queued locally',
                              ),
                            ),
                            ControlButton(
                              label: 'Return Home',
                              icon: Icons.home_rounded,
                              color: const Color(0xFFD79416),
                              onPressed: () => _setCommand(
                                'Return home command queued locally',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: joystickSize,
                          height: joystickSize,
                          child: VirtualJoystick(
                            label: 'MOVE',
                            icon: Icons.open_with_rounded,
                            onChanged: (value) => _setCommand(
                              value == Offset.zero
                                  ? 'Movement centered'
                                  : 'Movement input',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundDarkButton extends StatelessWidget {
  const _RoundDarkButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: const Color(0xD9111B30),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    ),
  );
}

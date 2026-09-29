import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../providers/drone_provider.dart';
import '../widgets/drone_widgets.dart';

class LiveFootagePage extends ConsumerStatefulWidget {
  const LiveFootagePage({super.key, required this.droneId});
  final String droneId;

  @override
  ConsumerState<LiveFootagePage> createState() => _LiveFootagePageState();
}

class _LiveFootagePageState extends ConsumerState<LiveFootagePage> {
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
    // The underlying fleet list is portrait, so restore that orientation
    // before it becomes visible again.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

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
          DroneVideoView(drone: drone),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: _BackButton(onPressed: () => context.pop()),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: TelemetryOverlay(drone: drone),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      'LIVE FEED · LOCAL PLACEHOLDER',
                      style: TextStyle(
                        color: Colors.white70,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xD9111B30),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: const Padding(
        padding: EdgeInsets.all(13),
        child: Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
    ),
  );
}

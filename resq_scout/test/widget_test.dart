import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:resq_scout/app/app.dart';
import 'package:resq_scout/models/drone.dart';
import 'package:resq_scout/models/emergency_action.dart';
import 'package:resq_scout/providers/rescue_session_provider.dart';
import 'package:resq_scout/screens/drone_control_page.dart';
import 'package:resq_scout/screens/live_footage_page.dart';
import 'package:resq_scout/screens/manual_control_page.dart';
import 'package:resq_scout/widgets/emergency_hold_button.dart';

void main() {
  testWidgets('home dashboard renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RescueVisionApp()));

    expect(find.text('ResQVision'), findsOneWidget);
  });

  testWidgets('emergency hold only activates after two seconds', (
    WidgetTester tester,
  ) async {
    var activationCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: EmergencyHoldButton(
              label: 'Hold to activate',
              icon: Icons.sos_rounded,
              color: Colors.red,
              onActivated: () => activationCount++,
            ),
          ),
        ),
      ),
    );

    final button = find.text('Hold to activate');
    final earlyRelease = await tester.startGesture(tester.getCenter(button));
    await tester.pump(const Duration(milliseconds: 900));
    await earlyRelease.up();
    await tester.pump();
    expect(activationCount, 0);

    final completedHold = await tester.startGesture(tester.getCenter(button));
    await tester.pump(const Duration(seconds: 2));
    await completedHold.up();
    await tester.pump();
    expect(activationCount, 1);
  });

  testWidgets('drone control opens manual control for an expanded drone', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_droneTestApp());
    expect(find.text('Drone Control'), findsOneWidget);

    await tester.tap(find.text('Drone A'));
    await tester.pumpAndSettle();
    expect(find.text('Live Footage').hitTestable(), findsOneWidget);
    expect(find.text('Manual Control').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Manual Control').hitTestable());
    await tester.pumpAndSettle();
    expect(find.text('Drone A · Manual control'), findsOneWidget);
    expect(find.text('Land'), findsOneWidget);
  });

  testWidgets('drone list fits a portrait phone without overflow', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_droneTestApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drone A'));
    await tester.pumpAndSettle();

    expect(find.text('Manual Control').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('emergency session can be submitted, progress, and reset', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final session = container.read(rescueSessionProvider.notifier);
    session.submitEmergency(EmergencyActionType.medical);

    expect(
      container
          .read(rescueSessionProvider)
          .statusFor(EmergencyActionType.medical),
      EmergencyRequestStatus.dispatched,
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    expect(
      container
          .read(rescueSessionProvider)
          .statusFor(EmergencyActionType.medical),
      EmergencyRequestStatus.enRoute,
    );

    session.cancelEmergency(EmergencyActionType.medical);
    expect(
      container
          .read(rescueSessionProvider)
          .statusFor(EmergencyActionType.medical),
      EmergencyRequestStatus.idle,
    );
  });

  test('drone serializes cleanly for a future backend', () {
    final drone = Drone.fromJson({
      'id': 'drone-test',
      'name': 'Test Drone',
      'status': 'active',
      'location': 'Sector A',
      'batteryPercentage': 83,
      'altitudeMeters': 42.5,
      'speedKmh': 20,
      'signalDbm': -67,
      'lastUpdated': '2026-09-21T12:00:00.000Z',
      'videoAvailable': true,
    });

    expect(drone.toJson()['status'], 'active');
    expect(drone.toJson()['altitudeMeters'], 42.5);
  });
}

Widget _droneTestApp() => ProviderScope(
  child: MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: '/drones',
      routes: [
        GoRoute(
          path: '/drones',
          builder: (_, _) => const DroneControlPage(),
          routes: [
            GoRoute(
              path: ':droneId/live',
              builder: (_, state) =>
                  LiveFootagePage(droneId: state.pathParameters['droneId']!),
            ),
            GoRoute(
              path: ':droneId/manual',
              builder: (_, state) =>
                  ManualControlPage(droneId: state.pathParameters['droneId']!),
            ),
          ],
        ),
      ],
    ),
  ),
);

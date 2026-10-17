import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resq_scout/app/app.dart';
import 'package:resq_scout/data/backend_api.dart';
import 'package:resq_scout/models/drone.dart';
import 'package:resq_scout/screens/manual_control_page.dart';
import 'package:resq_scout/widgets/backend_collection_page.dart';
import 'package:resq_scout/widgets/emergency_hold_button.dart';

void main() {
  testWidgets('home dashboard renders without demo records', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RescueVisionApp()));

    expect(find.text('ResQVision'), findsOneWidget);
    expect(find.textContaining('Drone A'), findsNothing);
  });

  testWidgets('backend collection displays an honest empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessTokenProvider.overrideWith(_TestAccessTokenNotifier.new),
          workspaceRecordsProvider('drones')
              .overrideWith((ref) async => <Map<String, dynamic>>[]),
        ],
        child: const MaterialApp(
          home: BackendCollectionPage(
            title: 'Fleet',
            subtitle: 'Backend fleet records',
            collection: 'drones',
            icon: Icons.flight_outlined,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Fleet yet'), findsOneWidget);
    expect(find.textContaining('backend /workspace/drones'), findsOneWidget);
  });

  testWidgets('backend collection renders dynamically supplied records', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workspaceRecordsProvider('drones').overrideWith(
            (ref) async => [
              {
                'id': 'record-1',
                'name': 'Live backend aircraft',
                'status': 'ready',
              },
            ],
          ),
        ],
        child: const MaterialApp(
          home: BackendCollectionPage(
            title: 'Fleet',
            subtitle: 'Backend fleet records',
            collection: 'drones',
            icon: Icons.flight_outlined,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live backend aircraft'), findsOneWidget);
    expect(find.textContaining('ready'), findsOneWidget);
  });

  testWidgets('manual control clearly states it is unavailable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ManualControlPage(droneId: 'aircraft-1')),
    );

    expect(find.text('Control · aircraft-1'), findsOneWidget);
    expect(find.textContaining('ELRS handset'), findsOneWidget);
  });

  testWidgets('emergency hold activates only after two seconds', (
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

  test('drone serializes cleanly for backend data', () {
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

class _TestAccessTokenNotifier extends AccessTokenNotifier {
  @override
  String? build() => 'test-token';
}

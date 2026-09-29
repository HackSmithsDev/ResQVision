import 'package:go_router/go_router.dart';

import '../../screens/ai_insights_page.dart';
import '../../screens/drone_control_page.dart';
import '../../screens/home_screen.dart';
import '../../screens/live_footage_page.dart';
import '../../screens/manual_control_page.dart';
import '../../screens/missions_page.dart';
import '../../screens/profile_page.dart';
import '../../screens/reports_page.dart';
import '../../screens/rescue_mode_screen.dart';
import '../../screens/settings_page.dart';
import '../../screens/team_communication_page.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const rescueMode = '/rescue-mode';
  static const droneControl = '/drones';
  static const teamCommunication = '/communications';
  static const aiInsights = '/ai-insights';
  static const aiChat = '/ai-insights?startAtChat=true';
  static const missions = '/missions';
  static const reports = '/reports';
  static const settings = '/settings';
  static const profile = '/profile';
  static const liveFootage = '/drones/:droneId/live';
  static const manualControl = '/drones/:droneId/manual';

  static String liveFootageFor(String droneId) => '/drones/$droneId/live';
  static String manualControlFor(String droneId) => '/drones/$droneId/manual';
}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (_, _) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'rescue-mode',
          builder: (_, _) => const RescueModeScreen(),
        ),
        GoRoute(
          path: 'drones',
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
        GoRoute(
          path: 'communications',
          builder: (_, _) => const TeamCommunicationPage(),
        ),
        GoRoute(
          path: 'ai-insights',
          builder: (_, state) => AIInsightsPage(
            startAtChat: state.uri.queryParameters['startAtChat'] == 'true',
          ),
        ),
        GoRoute(path: 'missions', builder: (_, _) => const MissionsPage()),
        GoRoute(path: 'reports', builder: (_, _) => const ReportsPage()),
        GoRoute(path: 'settings', builder: (_, _) => const SettingsPage()),
        GoRoute(path: 'profile', builder: (_, _) => const ProfilePage()),
      ],
    ),
  ],
);

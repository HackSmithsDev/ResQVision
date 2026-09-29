import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../app/theme/app_colors.dart';
import '../data/mock_emergency_data.dart';
import '../models/emergency_action.dart';
import '../models/rescue_session.dart';
import '../providers/rescue_session_provider.dart';
import '../widgets/emergency_action_bottom_sheet.dart';
import '../widgets/maps/rescue_map.dart';
import '../widgets/rescue_widgets.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openRescueMode(BuildContext context) {
    context.push(AppRoutes.rescueMode);
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _openEmergencyAction(BuildContext context, EmergencyActionType type) {
    showEmergencyActionBottomSheet(
      context: context,
      type: type,
      onViewMap: () => _openRescueMode(context),
    );
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        return; // already home
      case 1:
        context.go(AppRoutes.missions);
      case 2:
        context.push(AppRoutes.aiChat);
      case 3:
        context.push(AppRoutes.settings);
    }
  }

  void _openProfile(BuildContext context) {
    context.push(AppRoutes.profile);
  }

  void _openDroneControl(BuildContext context) {
    context.push(AppRoutes.droneControl);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(rescueSessionProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  onNotify: () =>
                      _message(context, 'You have 1 critical alert'),
                  onProfile: () => _openProfile(context),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              // const SliverToBoxAdapter(child: _SearchField()),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverToBoxAdapter(
                child: _MapPreview(onOpen: () => _openRescueMode(context)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _AlertCard(onTap: () => _openRescueMode(context)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: _MissionSection(
                  onOpenMission: () => _onNavTap(context, 1),
                  onOpenDroneControl: () => _openDroneControl(context),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Text(
                  'Emergency actions',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: _ActionGrid(
                  session: session,
                  onActionTap: (type) => _openEmergencyAction(context, type),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              SliverToBoxAdapter(
                child: Text(
                  'Additional tools',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: _Tools(message: (message) => _message(context, message)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) => _onNavTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Missions',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.flight_outlined),
          //   label: 'Drones',
          // ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onNotify, required this.onProfile});
  final VoidCallback onNotify;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.landscape, size: 46, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ResQVision',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: onNotify,
        icon: Badge(
          child: const Icon(Icons.notifications_none_rounded, size: 30),
        ),
      ),
      InkWell(
        onTap: onProfile,
        customBorder: const CircleBorder(),
        child: CircleAvatar(
          backgroundColor: AppColors.avatar,
          child: const Text(
            'V',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
        ),
      ),
    ],
  );
}

// class _SearchField extends StatelessWidget {
//   const _SearchField();

//   @override
//   Widget build(BuildContext context) => TextField(
//     decoration: InputDecoration(
//       hintText: 'Search missions, locations, or teams...',
//       prefixIcon: const Icon(Icons.search),
//       filled: true,
//       fillColor: Colors.white,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(16),
//         borderSide: BorderSide.none,
//       ),
//     ),
//   );
// }

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.onOpen});
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      height: 300,
      child: Stack(
        children: [
          Positioned.fill(child: RescueMap(onDroneTap: onOpen)),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .12),
                ),
              ),
            ),
          ),
          Positioned(top: 18, left: 18, child: _weather()),
          Positioned(top: 18, right: 16, child: _toggle(context)),
          const Positioned(
            left: 14,
            bottom: 16,
            child: Column(
              children: [
                RoundToolButton(icon: Icons.layers),
                SizedBox(height: 8),
                RoundToolButton(icon: Icons.my_location),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _weather() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xE9142230),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌧  18°C',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Light rain · Uttarkashi, UK',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    ),
  );

  Widget _toggle(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(14),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, color: AppColors.primary),
            SizedBox(width: 6),
            Text('Rescue mode', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    ),
  );
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFFFEAEC),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: const Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.danger),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Alert',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Possible landslide near Sector B',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

class _MissionSection extends StatelessWidget {
  const _MissionSection({
    required this.onOpenMission,
    required this.onOpenDroneControl,
  });
  final VoidCallback onOpenMission;
  final VoidCallback onOpenDroneControl;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 178,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: GestureDetector(
            onTap: onOpenMission,
            child: _whiteCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current mission',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Rescue B27',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '📍 Uttarkashi, Uttarakhand',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: onOpenMission,
                    child: const Text('View details →'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _whiteCard(
            context,
            child: InkWell(
              onTap: onOpenDroneControl,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_fill_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 9),
                  Text(
                    'Live Drone Feed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _whiteCard(BuildContext context, {required Widget child}) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(18),
    boxShadow: const [
      BoxShadow(color: Color(0x110D1B2A), blurRadius: 12, offset: Offset(0, 5)),
    ],
  ),
  child: child,
);

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.session, required this.onActionTap});
  final RescueSession session;
  final ValueChanged<EmergencyActionType> onActionTap;

  @override
  Widget build(BuildContext context) {
    final actions = mockEmergencyActions.values.toList();
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.33,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = actions[index];
        return Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: () => onActionTap(item.type),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: item.accent, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    item.shortTitle,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subtitleFor(item),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _subtitleFor(EmergencyActionDetails details) {
    if (!session.isRequested(details.type)) return details.subtitle;
    return details.isHelicopter ? 'H-02 en route · ETA 05:00' : 'Requested';
  }
}

class _Tools extends StatelessWidget {
  const _Tools({required this.message});
  final void Function(String) message;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _tool(
        context,
        Icons.chat_bubble_outline,
        'Team communication',
        'Talk to your team',
        () => context.push(AppRoutes.teamCommunication),
      ),
      const SizedBox(height: 10),
      _tool(
        context,
        Icons.gamepad_outlined,
        'Drone control',
        'Monitor and manage your drone fleet',
        () => context.push(AppRoutes.droneControl),
      ),
      const SizedBox(height: 10),
      _tool(
        context,
        Icons.psychology_outlined,
        'AI insights',
        'View analysis',
        () => context.push(AppRoutes.aiInsights),
      ),
    ],
  );

  Widget _tool(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, [
    VoidCallback? onTap,
  ]) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap ?? () => message('$title opened'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    ),
  );
}

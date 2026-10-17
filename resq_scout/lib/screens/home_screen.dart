import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../data/backend_api.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: const Text('ResQVision'),
      actions: [
        IconButton(
          tooltip: 'Account and settings',
          onPressed: () => context.push(AppRoutes.profile),
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Operational data',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        const Text(
          'Records load from your ResQVision account. No sample fleet or mission data is shown.',
        ),
        const SizedBox(height: 18),
        for (final section in _sections) ...[
          _CollectionSummary(
            title: section.title,
            collection: section.collection,
            icon: section.icon,
            onTap: () => context.push(section.route),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Account settings'),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 1:
            context.push(AppRoutes.missions);
          case 2:
            context.push(AppRoutes.aiChat);
          case 3:
            context.push(AppRoutes.settings);
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Missions'),
        NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'AI'),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          label: 'Settings',
        ),
      ],
    ),
  );
}

class _CollectionSection {
  const _CollectionSection({
    required this.title,
    required this.collection,
    required this.route,
    required this.icon,
  });

  final String title;
  final String collection;
  final String route;
  final IconData icon;
}

const _sections = [
  _CollectionSection(
    title: 'Fleet',
    collection: 'drones',
    route: AppRoutes.droneControl,
    icon: Icons.flight_outlined,
  ),
  _CollectionSection(
    title: 'Missions',
    collection: 'missions',
    route: AppRoutes.missions,
    icon: Icons.map_outlined,
  ),
  _CollectionSection(
    title: 'Alerts',
    collection: 'notifications',
    route: AppRoutes.reports,
    icon: Icons.notifications_outlined,
  ),
  _CollectionSection(
    title: 'Reports',
    collection: 'reports',
    route: AppRoutes.reports,
    icon: Icons.assignment_outlined,
  ),
];

class _CollectionSummary extends ConsumerWidget {
  const _CollectionSummary({
    required this.title,
    required this.collection,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String collection;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(workspaceRecordsProvider(collection));
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: records.when(
          loading: () => const Text('Loading from backend…'),
          error: (error, _) => Text('Unavailable: $error'),
          data: (items) => Text(
            items.isEmpty
                ? 'No records'
                : '${items.length} ${items.length == 1 ? 'record' : 'records'}',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

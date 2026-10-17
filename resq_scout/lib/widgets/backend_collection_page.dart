import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../data/backend_api.dart';

class BackendCollectionPage extends ConsumerWidget {
  const BackendCollectionPage({
    required this.title,
    required this.subtitle,
    required this.collection,
    required this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final String collection;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(workspaceRecordsProvider(collection));
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text(subtitle),
          ),
          Expanded(
            child: records.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _RequestError(
                error: error,
                requiresSignIn:
                    error is BackendApiException && error.statusCode == 401,
                onRetry: () => ref.invalidate(
                  workspaceRecordsProvider(collection),
                ),
              ),
              data: (items) => items.isEmpty
                  ? _EmptyCollection(
                      title: title,
                      collection: collection,
                      icon: icon,
                      requiresSignIn:
                          ref.watch(accessTokenProvider) == null,
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.refresh(
                        workspaceRecordsProvider(collection).future,
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _RecordCard(record: items[index], icon: icon),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({
    required this.title,
    required this.collection,
    required this.icon,
    required this.requiresSignIn,
  });

  final String title;
  final String collection;
  final IconData icon;
  final bool requiresSignIn;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            requiresSignIn ? 'Sign in to load $title' : 'No $title yet',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            requiresSignIn
                ? 'Connect to your ResQVision account to load your data.'
                : 'Records for this account will appear here when available.',
            textAlign: TextAlign.center,
          ),
          if (requiresSignIn) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.settings),
              child: const Text('Open account settings'),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Source: backend /workspace/$collection',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

class _RequestError extends StatelessWidget {
  const _RequestError({
    required this.error,
    required this.requiresSignIn,
    required this.onRetry,
  });

  final Object error;
  final bool requiresSignIn;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42),
          const SizedBox(height: 12),
          Text(requiresSignIn ? 'Sign in to load backend data' : 'Could not load backend data'),
          const SizedBox(height: 6),
          if (!requiresSignIn) Text(error.toString(), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          if (requiresSignIn)
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.settings),
              child: const Text('Open account settings'),
            ),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.icon});

  final Map<String, dynamic> record;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final title = _firstValue(record, const ['title', 'name', 'callsign', 'id']);
    final subtitle = _firstValue(
      record,
      const ['description', 'summary', 'location', 'status'],
      excluded: title,
    );
    final details = record.entries
        .where(
          (entry) =>
              entry.key != 'id' &&
              entry.value != null &&
              entry.value is! Map &&
              entry.value is! List,
        )
        .map((entry) => '${_label(entry.key)}: ${entry.value}')
        .toList();

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title ?? 'Record'),
        subtitle: Text(
          [?subtitle, ...details].join('\n'),
        ),
        isThreeLine: details.length > 1,
      ),
    );
  }

  static String? _firstValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String? excluded,
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty && value != excluded) {
        return value.toString();
      }
    }
    return null;
  }

  static String _label(String key) =>
      key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match[1]}');
}

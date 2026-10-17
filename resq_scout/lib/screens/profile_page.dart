import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/backend_api.dart';
import '../widgets/backend_access_card.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(backendProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const BackendAccessCard(),
          const SizedBox(height: 12),
          profile.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ProfileState(
              message: ref.watch(sessionProvider).asData?.value == null
                  ? 'Sign in to load your backend profile.'
                  : error.toString(),
              onRetry: () => ref.invalidate(backendProfileProvider),
            ),
            data: (data) => Card(
              child: Column(
                children: [
                  _ProfileValue(label: 'Name', value: data['full_name']),
                  _ProfileValue(label: 'Email', value: data['email']),
                  _ProfileValue(label: 'Role', value: data['role']),
                  _ProfileValue(
                    label: 'Account approved',
                    value: data['is_approved'],
                  ),
                  _ProfileValue(
                    label: 'Last active',
                    value: data['last_active'],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Settings'),
          ),
        ],
      ),
    );
  }
}

class _ProfileState extends StatelessWidget {
  const _ProfileState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.person_outline),
      title: Text(message),
      trailing: IconButton(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
      ),
    ),
  );
}

class _ProfileValue extends StatelessWidget {
  const _ProfileValue({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final text = value == null || value.toString().isEmpty
        ? 'Not provided'
        : value.toString();
    return ListTile(title: Text(label), subtitle: Text(text));
  }
}

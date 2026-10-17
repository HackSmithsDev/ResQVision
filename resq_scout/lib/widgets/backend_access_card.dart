import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backend_api.dart';

class BackendAccessCard extends ConsumerStatefulWidget {
  const BackendAccessCard({super.key});

  @override
  ConsumerState<BackendAccessCard> createState() => _BackendAccessCardState();
}

class _BackendAccessCardState extends ConsumerState<BackendAccessCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      ref.invalidate(backendProfileProvider);
      ref.invalidate(workspaceRecordsProvider);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: session.isLoading
            ? const Center(child: CircularProgressIndicator())
            : session.hasError
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Could not restore your saved session.'),
                  const SizedBox(height: 8),
                  Text(
                    session.error.toString(),
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(sessionProvider),
                    child: const Text('Retry'),
                  ),
                ],
              )
            : session.value != null
            ? ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_done_outlined),
                title: const Text('Backend account connected'),
                trailing: TextButton(
                  onPressed: () async {
                    await ref.read(sessionProvider.notifier).signOut();
                    ref.invalidate(backendProfileProvider);
                    ref.invalidate(workspaceRecordsProvider);
                  },
                  child: const Text('Sign out'),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Connect to ResQVision',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _signIn,
                    child: Text(_isSubmitting ? 'Connecting…' : 'Sign in'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your session is saved in secure device storage and renewed automatically.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'API: $backendBaseUrl',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}

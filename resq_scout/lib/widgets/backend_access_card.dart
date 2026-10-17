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
      final result = await ref.read(backendApiProvider).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      ref
          .read(accessTokenProvider.notifier)
          .setToken(result['access_token'] as String);
      ref.invalidate(backendProfileProvider);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSignedIn = ref.watch(accessTokenProvider) != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isSignedIn
            ? ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.cloud_done_outlined),
                title: const Text('Backend account connected'),
                trailing: TextButton(
                  onPressed: () {
                    ref.read(accessTokenProvider.notifier).setToken(null);
                    ref.invalidate(backendProfileProvider);
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

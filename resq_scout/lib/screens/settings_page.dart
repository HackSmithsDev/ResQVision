import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushNotifications = true;
  bool _locationSharing = true;
  bool _offlineMaps = false;

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 18, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                children: [
                  _ProfileCard(onEdit: () => _message('Edit profile')),
                  const SizedBox(height: 20),
                  const _SectionLabel('Notifications'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SwitchRow(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push notifications',
                        subtitle: 'Critical alerts and mission updates',
                        value: _pushNotifications,
                        onChanged: (v) =>
                            setState(() => _pushNotifications = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Field settings'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SwitchRow(
                        icon: Icons.location_on_outlined,
                        title: 'Location sharing',
                        subtitle: 'Share your live position with your team',
                        value: _locationSharing,
                        onChanged: (v) => setState(() => _locationSharing = v),
                      ),
                      const _Divider(),
                      _SwitchRow(
                        icon: Icons.download_for_offline_outlined,
                        title: 'Offline maps',
                        subtitle: 'Cache terrain maps for low-signal areas',
                        value: _offlineMaps,
                        onChanged: (v) => setState(() => _offlineMaps = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Appearance'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _SwitchRow(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark mode',
                        subtitle: 'Easier on the eyes in low light',
                        value: isDarkMode,
                        onChanged: ref
                            .read(themeModeProvider.notifier)
                            .setDarkMode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Support'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    children: [
                      _NavRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & support',
                        onTap: () => _message('Help & support'),
                      ),
                      const _Divider(),
                      _NavRow(
                        icon: Icons.description_outlined,
                        title: 'Terms & privacy policy',
                        onTap: () => _message('Terms & privacy policy'),
                      ),
                      const _Divider(),
                      _NavRow(
                        icon: Icons.info_outline_rounded,
                        title: 'About ResQVision',
                        subtitle: 'Version 1.0.0',
                        onTap: () => _message('About ResQVision'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: const Color(0xFFFFEAEC),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _message('Signed out'),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.danger),
                            SizedBox(width: 8),
                            Text(
                              'Log out',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.onEdit});
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.avatar,
          child: Text(
            'V',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rescuer V',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Team Alpha-02 · Uttarkashi',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onEdit, child: const Text('Edit')),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 13,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      letterSpacing: .3,
    ),
  );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: 54,
    color: Theme.of(context).colorScheme.outlineVariant,
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}

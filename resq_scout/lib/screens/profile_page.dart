import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/router/app_router.dart';
import '../app/theme/app_colors.dart';
import '../data/mock_profile_data.dart';
import '../models/user_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const profile = mockUserProfile;
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
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push(AppRoutes.settings),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                children: [
                  _ProfileHeaderCard(
                    profile: profile,
                    onEdit: () => _message(context, 'Edit profile'),
                  ),
                  const SizedBox(height: 20),
                  _StatsRow(profile: profile),
                  const SizedBox(height: 20),
                  const _SectionLabel('Contact'),
                  const SizedBox(height: 8),
                  _InfoGroup(
                    children: [
                      _InfoRow(icon: Icons.phone_outlined, value: profile.phone),
                      const _Divider(),
                      _InfoRow(icon: Icons.email_outlined, value: profile.email),
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        value: profile.sector,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('Certifications'),
                  const SizedBox(height: 8),
                  _InfoGroup(
                    children: [
                      for (var i = 0; i < profile.certifications.length; i++) ...[
                        if (i > 0) const _Divider(),
                        _InfoRow(
                          icon: Icons.verified_outlined,
                          value: profile.certifications[i],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => context.push(AppRoutes.settings),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE7ECF3)),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 13),
                            Expanded(
                              child: Text(
                                'Go to settings',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Material(
                    color: const Color(0xFFFFEAEC),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _message(context, 'Signed out'),
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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile, required this.onEdit});
  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE7ECF3)),
    ),
    child: Column(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: AppColors.avatar,
          child: Text(
            profile.initials,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              fontSize: 28,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          profile.name,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 3),
        Text(
          '${profile.role} · ${profile.team}',
          style: const TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 3),
        Text(
          profile.activeSince,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: const Text('Edit profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _statCard(
          Icons.task_alt_rounded,
          '${profile.missionsCompleted}',
          'Missions completed',
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _statCard(
          Icons.schedule,
          '${profile.hoursInField}h',
          'Hours in field',
        ),
      ),
    ],
  );

  Widget _statCard(IconData icon, String value, String label) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE7ECF3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
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
    style: const TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 13,
      color: AppColors.muted,
      letterSpacing: .3,
    ),
  );
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE7ECF3)),
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 54, color: Color(0xFFEEF1F5));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
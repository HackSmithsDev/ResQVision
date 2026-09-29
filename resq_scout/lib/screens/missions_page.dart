import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../data/mock_missions_data.dart';
import '../models/mission.dart';

enum _MissionFilter { all, active, planned, completed }

class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  _MissionFilter _filter = _MissionFilter.all;

  List<Mission> get _active =>
      mockMissions.where((m) => m.status == MissionStatus.active).toList();
  List<Mission> get _planned =>
      mockMissions.where((m) => m.status == MissionStatus.planned).toList();
  List<Mission> get _completed => mockMissions
      .where((m) => m.status == MissionStatus.completed)
      .toList();

  void _showMissionDetails(Mission mission) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mission.title),
        content: Text(mission.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          const _PageHeader(
            title: 'Missions',
            subtitle: 'Rescue operations, search & relief',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
            child: _FilterChips(
              filter: _filter,
              counts: (
                all: mockMissions.length,
                active: _active.length,
                planned: _planned.length,
                completed: _completed.length,
              ),
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(child: _body()),
        ],
      ),
    ),
  );

  Widget _body() {
    switch (_filter) {
      case _MissionFilter.all:
        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            _SectionHeader(
              title: 'Active Missions',
              trailing: '${_active.length} ongoing',
            ),
            const SizedBox(height: 10),
            for (final m in _active) ...[
              _MissionCard(mission: m, onTap: () => _showMissionDetails(m)),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            _SectionHeader(
              title: 'Upcoming Missions',
              trailing: '${_planned.length} planned',
            ),
            const SizedBox(height: 10),
            for (final m in _planned) ...[
              _PlannedMissionCard(mission: m),
              const SizedBox(height: 12),
            ],
          ],
        );
      case _MissionFilter.active:
        return _flatList(_active, planned: false);
      case _MissionFilter.planned:
        return _flatList(_planned, planned: true);
      case _MissionFilter.completed:
        return _flatList(_completed, planned: false);
    }
  }

  Widget _flatList(List<Mission> missions, {required bool planned}) =>
      ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
        itemCount: missions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => planned
            ? _PlannedMissionCard(mission: missions[i])
            : _MissionCard(
                mission: missions[i],
                onTap: () => _showMissionDetails(missions[i]),
              ),
      );
}

/// Shared back-button header, matching the pattern already used by
/// AIInsightsPage's `_AIPageHeader` — kept local to each file rather than
/// imported from a shared widgets file.
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 18, 10),
    child: Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filter,
    required this.counts,
    required this.onChanged,
  });

  final _MissionFilter filter;
  final ({int all, int active, int planned, int completed}) counts;
  final ValueChanged<_MissionFilter> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _chip('All (${counts.all})', _MissionFilter.all),
        const SizedBox(width: 8),
        _chip('Active (${counts.active})', _MissionFilter.active),
        const SizedBox(width: 8),
        _chip('Planned (${counts.planned})', _MissionFilter.planned),
        const SizedBox(width: 8),
        _chip('Completed (${counts.completed})', _MissionFilter.completed),
      ],
    ),
  );

  Widget _chip(String label, _MissionFilter value) {
    final selected = value == filter;
    return Material(
      color: selected ? AppColors.primary : const Color(0xFFF0F4FA),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF476185),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.ink,
        ),
      ),
      Text(trailing, style: const TextStyle(color: AppColors.muted)),
    ],
  );
}

class _SeverityPresentation {
  const _SeverityPresentation(this.label, this.color, this.background);
  final String label;
  final Color color;
  final Color background;

  static _SeverityPresentation forSeverity(String? severity) =>
      switch (severity) {
        'high' => const _SeverityPresentation(
          'HIGH',
          Color(0xFFD52C3E),
          Color(0xFFFFE0E3),
        ),
        'medium' => const _SeverityPresentation(
          'MEDIUM',
          Color(0xFFD79416),
          Color(0xFFFCEBD1),
        ),
        _ => const _SeverityPresentation(
          'LOW',
          Color(0xFF18AE73),
          Color(0xFFDCF3E7),
        ),
      };
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.mission, required this.onTap});
  final Mission mission;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final severity = _SeverityPresentation.forSeverity(mission.severity);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7ECF3)),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 11, color: severity.color),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      mission.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: severity.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      severity.label,
                      style: TextStyle(
                        color: severity.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      mission.sector,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF98A6BC)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                mission.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  if (mission.rescuers != null)
                    _stat(Icons.people_outline, '${mission.rescuers} Rescuers'),
                  if (mission.drones != null)
                    _stat(
                      Icons.airplanemode_active,
                      '${mission.drones} Drones',
                    ),
                  if (mission.duration != null)
                    _stat(Icons.access_time, mission.duration!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.muted),
      const SizedBox(width: 3),
      Text(text, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
    ],
  );
}

class _PlannedMissionCard extends StatelessWidget {
  const _PlannedMissionCard({required this.mission});
  final Mission mission;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE7ECF3)),
    ),
    padding: const EdgeInsets.all(14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE8FB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'PLANNED',
                      style: TextStyle(
                        color: Color(0xFF1765CF),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Planned · ${mission.scheduledLabel}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    mission.sector,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                mission.description,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
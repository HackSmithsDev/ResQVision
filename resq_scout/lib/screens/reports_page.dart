import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../data/mock_reports_data.dart';
import '../models/mission_report.dart';

enum _ReportFilter { all, draft, submitted, reviewed }

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  _ReportFilter _filter = _ReportFilter.all;

  List<MissionReport> get _filtered {
    switch (_filter) {
      case _ReportFilter.all:
        return mockReports;
      case _ReportFilter.draft:
        return mockReports.where((r) => r.status == ReportStatus.draft).toList();
      case _ReportFilter.submitted:
        return mockReports
            .where((r) => r.status == ReportStatus.submitted)
            .toList();
      case _ReportFilter.reviewed:
        return mockReports
            .where((r) => r.status == ReportStatus.reviewed)
            .toList();
    }
  }

  void _showReportDetails(MissionReport report) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.missionTitle),
        content: Text(report.summary),
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
          Padding(
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
                        'Reports',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.ink,
                            ),
                      ),
                      const Text(
                        'Mission reports and after-action summaries',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            child: _FilterChips(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _ReportCard(
                report: _filtered[i],
                onTap: () => _showReportDetails(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.filter, required this.onChanged});
  final _ReportFilter filter;
  final ValueChanged<_ReportFilter> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _chip('All', _ReportFilter.all),
        const SizedBox(width: 8),
        _chip('Draft', _ReportFilter.draft),
        const SizedBox(width: 8),
        _chip('Submitted', _ReportFilter.submitted),
        const SizedBox(width: 8),
        _chip('Reviewed', _ReportFilter.reviewed),
      ],
    ),
  );

  Widget _chip(String label, _ReportFilter value) {
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

class _StatusPresentation {
  const _StatusPresentation(this.label, this.color, this.background);
  final String label;
  final Color color;
  final Color background;

  static _StatusPresentation forStatus(ReportStatus status) => switch (status) {
    ReportStatus.draft => const _StatusPresentation(
      'DRAFT',
      Color(0xFF667085),
      Color(0xFFEEF1F5),
    ),
    ReportStatus.submitted => const _StatusPresentation(
      'SUBMITTED',
      Color(0xFFD79416),
      Color(0xFFFCEBD1),
    ),
    ReportStatus.reviewed => const _StatusPresentation(
      'REVIEWED',
      Color(0xFF18AE73),
      Color(0xFFDCF3E7),
    ),
  };
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report, required this.onTap});
  final MissionReport report;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _StatusPresentation.forStatus(report.status);
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
                  Expanded(
                    child: Text(
                      report.missionTitle,
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
                      color: status.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: status.color,
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
                  Text(
                    report.sector,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                report.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.muted),
                  const SizedBox(width: 3),
                  Text(
                    report.filedBy,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.schedule, size: 14, color: AppColors.muted),
                  const SizedBox(width: 3),
                  Text(
                    report.dateLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                  if (report.attachmentsCount > 0) ...[
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.attach_file_rounded,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${report.attachmentsCount}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF98A6BC)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
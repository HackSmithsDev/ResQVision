enum ReportStatus { draft, submitted, reviewed }

/// An after-action / status report filed against a mission. Kept as plain
/// Dart (no Flutter imports) — presentation is derived in the UI layer.
class MissionReport {
  const MissionReport({
    required this.id,
    required this.missionTitle,
    required this.sector,
    required this.summary,
    required this.status,
    required this.filedBy,
    required this.dateLabel,
    this.severity,
    this.attachmentsCount = 0,
  });

  final String id;
  final String missionTitle;
  final String sector;
  final String summary;
  final ReportStatus status;
  final String filedBy;
  final String dateLabel;

  /// 'high' | 'medium' | 'low'. Null when the report has no severity tag.
  final String? severity;
  final int attachmentsCount;

  factory MissionReport.fromJson(Map<String, dynamic> json) => MissionReport(
    id: json['id'] as String,
    missionTitle: json['missionTitle'] as String,
    sector: json['sector'] as String,
    summary: json['summary'] as String,
    status: ReportStatus.values.byName(json['status'] as String),
    filedBy: json['filedBy'] as String,
    dateLabel: json['dateLabel'] as String,
    severity: json['severity'] as String?,
    attachmentsCount: json['attachmentsCount'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'missionTitle': missionTitle,
    'sector': sector,
    'summary': summary,
    'status': status.name,
    'filedBy': filedBy,
    'dateLabel': dateLabel,
    'severity': severity,
    'attachmentsCount': attachmentsCount,
  };
}
enum MissionStatus { active, planned, completed }

/// A rescue/relief mission shown on the Missions page.
///
/// Kept as plain Dart (no Flutter imports) to match the style of
/// [AIInsight] — presentation (colors/icons) is derived in the UI layer
/// from [severity], not stored on the model.
class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.sector,
    required this.description,
    required this.status,
    this.severity,
    this.rescuers,
    this.drones,
    this.duration,
    this.scheduledLabel,
  });

  final String id;
  final String title;
  final String sector;
  final String description;
  final MissionStatus status;

  /// 'high' | 'medium' | 'low'. Null for missions with no assigned priority.
  final String? severity;

  final int? rescuers;
  final int? drones;

  /// Elapsed/ongoing time label for active missions, e.g. "3h 20m", or a
  /// "Completed · 2 days ago" style label for completed ones.
  final String? duration;

  /// Human readable schedule label for planned missions, e.g.
  /// "Tomorrow, 10:30 AM".
  final String? scheduledLabel;

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'] as String,
    title: json['title'] as String,
    sector: json['sector'] as String,
    description: json['description'] as String,
    status: MissionStatus.values.byName(json['status'] as String),
    severity: json['severity'] as String?,
    rescuers: json['rescuers'] as int?,
    drones: json['drones'] as int?,
    duration: json['duration'] as String?,
    scheduledLabel: json['scheduledLabel'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'sector': sector,
    'description': description,
    'status': status.name,
    'severity': severity,
    'rescuers': rescuers,
    'drones': drones,
    'duration': duration,
    'scheduledLabel': scheduledLabel,
  };
}
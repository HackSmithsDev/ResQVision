enum AIInsightType {
  risk,
  survivors,
  route,
  environment,
  recommendation,
  dataSources,
}

enum AIInsightAction { none, openMap }

class AIInsight {
  const AIInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.label,
    this.severity,
    this.confidence,
    this.action = AIInsightAction.none,
    this.actionLabel,
    this.metadata = const {},
    this.items = const [],
  });

  final String id;
  final AIInsightType type;
  final String title;
  final String description;
  final String? label;
  final String? severity;
  final int? confidence;
  final AIInsightAction action;
  final String? actionLabel;
  final Map<String, dynamic> metadata;
  final List<String> items;

  factory AIInsight.fromJson(Map<String, dynamic> json) => AIInsight(
    id: json['id'] as String,
    type: AIInsightType.values.byName(json['type'] as String),
    title: json['title'] as String,
    description: json['description'] as String,
    label: json['label'] as String?,
    severity: json['severity'] as String?,
    confidence: json['confidence'] as int?,
    action: AIInsightAction.values.byName(json['action'] as String? ?? 'none'),
    actionLabel: json['actionLabel'] as String?,
    metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? const {}),
    items: List<String>.from(json['items'] as List? ?? const []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'label': label,
    'severity': severity,
    'confidence': confidence,
    'action': action.name,
    'actionLabel': actionLabel,
    'metadata': metadata,
    'items': items,
  };
}

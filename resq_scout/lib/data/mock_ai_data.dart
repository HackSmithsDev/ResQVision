import '../models/ai_chat_message.dart';
import '../models/ai_insight.dart';

const mockAIInsights = <AIInsight>[
  AIInsight(
    id: 'risk',
    type: AIInsightType.risk,
    label: 'Risk assessment',
    title: 'HIGH RISK',
    description: 'Possible landslide activity detected near Sector B.',
    confidence: 94,
    severity: 'high',
  ),
  AIInsight(
    id: 'survivors',
    type: AIInsightType.survivors,
    label: 'Survivor detection',
    title: '2 Possible Survivors',
    description: 'Detected by Drone A',
    confidence: 92,
    action: AIInsightAction.openMap,
    actionLabel: 'View on Map',
  ),
  AIInsight(
    id: 'route',
    type: AIInsightType.route,
    label: 'Route analysis',
    title: 'Western route recommended.',
    description: 'Eastern route: Landslide risk detected.',
    action: AIInsightAction.openMap,
    actionLabel: 'View Route',
  ),
  AIInsight(
    id: 'environment',
    type: AIInsightType.environment,
    label: 'Environmental conditions',
    title: 'Heavy Rainfall',
    description: 'Impact: Increased landslide probability.',
  ),
  AIInsight(
    id: 'recommendation',
    type: AIInsightType.recommendation,
    label: 'AI recommendation',
    title: 'Continue Drone A surveillance over Sector B.',
    description: 'Dispatch Team Alpha toward the detected survivor location.',
    action: AIInsightAction.openMap,
    actionLabel: 'View Mission Plan',
  ),
  AIInsight(
    id: 'sources',
    type: AIInsightType.dataSources,
    title: 'Data sources',
    description: '',
    items: ['Drone A', 'Drone B', 'Satellite imagery', 'Weather data'],
  ),
];

const mockSuggestedAIQuestions = <String>[
  'Is the eastern route safe?',
  'Where was the survivor detected?',
  'What should we do first?',
  'Show me the safest route.',
];
const mockInitialAIChatMessages = <AIChatMessage>[
  AIChatMessage(
    id: 'ai-welcome',
    text: 'How can I assist with Rescue B27? I can help with routes, risks, survivor locations, weather conditions, and mission planning.',
    isUser: false,
  ),
];

String mockAIReplyFor(String question) {
  final value = question.toLowerCase();
  if (value.contains('eastern') ||
      value.contains('route') ||
      value.contains('safe')) {
    return 'The eastern route is currently considered unsafe due to possible slope instability in recent drone imagery. The western route is recommended.';
  }
  if (value.contains('survivor') || value.contains('location')) {
    return 'Two possible survivors were detected approximately 120 metres northeast of your current position. The area is marked on the map.';
  }
  if (value.contains('weather') || value.contains('rain')) {
    return 'Heavy rainfall is currently increasing the landslide risk around Sector B.';
  }
  if (value.contains('what should') || value.contains('first')) {
    return 'Prioritize reaching the detected survivor while avoiding the eastern slope. Team Alpha should approach from the western route.';
  }
  return 'I do not have enough mission data to answer that confidently. Based on the current mission data, Sector B remains the highest-priority area.';
}

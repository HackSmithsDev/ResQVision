import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_ai_data.dart';
import '../models/ai_chat_message.dart';
import '../models/ai_insight.dart';

class AIState {
  const AIState({
    required this.insights,
    required this.suggestedQuestions,
    required this.messages,
    this.isTyping = false,
  });

  final List<AIInsight> insights;
  final List<String> suggestedQuestions;
  final List<AIChatMessage> messages;
  final bool isTyping;

  AIState copyWith({List<AIChatMessage>? messages, bool? isTyping}) => AIState(
    insights: insights,
    suggestedQuestions: suggestedQuestions,
    messages: messages ?? this.messages,
    isTyping: isTyping ?? this.isTyping,
  );
}

final aiProvider = NotifierProvider<AINotifier, AIState>(AINotifier.new);

class AINotifier extends Notifier<AIState> {
  @override
  AIState build() => const AIState(
    insights: mockAIInsights,
    suggestedQuestions: mockSuggestedAIQuestions,
    messages: mockInitialAIChatMessages,
  );

  void ask(String question) {
    if (question.isEmpty || state.isTyping) return;

    state = state.copyWith(
      messages: [
        ...state.messages,
        AIChatMessage(
          id: 'user-${DateTime.now().microsecondsSinceEpoch}',
          text: question,
          isUser: true,
        ),
      ],
      isTyping: true,
    );

    Future<void>.delayed(const Duration(milliseconds: 850), () {
      state = state.copyWith(
        messages: [
          ...state.messages,
          AIChatMessage(
            id: 'ai-${DateTime.now().microsecondsSinceEpoch}',
            text: mockAIReplyFor(question),
            isUser: false,
          ),
        ],
        isTyping: false,
      );
    });
  }
}

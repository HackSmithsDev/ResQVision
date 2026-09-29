import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/ai_chat_message.dart';
import '../models/ai_insight.dart';
import '../providers/ai_provider.dart';
import '../app/router/app_router.dart';
import '../widgets/rescue_widgets.dart';

class AIInsightsPage extends ConsumerStatefulWidget {
  const AIInsightsPage({super.key, this.startAtChat = false});

  final bool startAtChat;

  @override
  ConsumerState<AIInsightsPage> createState() => _AIInsightsPageState();
}

class _AIInsightsPageState extends ConsumerState<AIInsightsPage> {
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.startAtChat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      });
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _ask([String? suggestedQuestion]) {
    final question = (suggestedQuestion ?? _composerController.text).trim();
    if (question.isEmpty || ref.read(aiProvider).isTyping) return;
    _composerController.clear();
    ref.read(aiProvider.notifier).ask(question);
    _scrollToLatest();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<Widget> _insightWidgets(List<AIInsight> insights) => [
    for (final insight in insights) ...[
      if (insight.type == AIInsightType.dataSources)
        _DataSourcesCard(insight: insight)
      else
        _InsightCard(
          insight: insight,
          onAction: insight.action == AIInsightAction.openMap
              ? () => context.push(AppRoutes.rescueMode)
              : null,
        ),
      const SizedBox(height: 10),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const _AIPageHeader(),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                    sliver: SliverList.list(
                      children: [
                        const _MissionAssistantHeader(),
                        const SizedBox(height: 14),
                        ..._insightWidgets(aiState.insights),
                        const SizedBox(height: 22),
                        Text(
                          'Ask the AI about this mission',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: ink,
                              ),
                        ),
                        const SizedBox(height: 10),
                        _SuggestedQuestions(
                          questions: aiState.suggestedQuestions,
                          onSelected: _ask,
                        ),
                        const SizedBox(height: 16),
                        ...aiState.messages.map(
                          (message) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AIMessageBubble(message: message),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: aiState.isTyping
                              ? const _TypingIndicator()
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _AIComposer(controller: _composerController, onSend: _ask),
          ],
        ),
      ),
    );
  }
}

class _AIPageHeader extends StatelessWidget {
  const _AIPageHeader();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 18, 12),
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
                'AI Insights',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900, color: ink),
              ),
              const Text(
                'Rescue B27 • Uttarkashi',
                style: TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 11, color: Color(0xFF18AE73)),
                SizedBox(width: 6),
                Text(
                  'AI Online',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF476185),
                  ),
                ),
              ],
            ),
            Text(
              'Analyzing mission data',
              style: TextStyle(fontSize: 11, color: Color(0xFF667085)),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MissionAssistantHeader extends StatelessWidget {
  const _MissionAssistantHeader();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE8F4FF), Color(0xFFF3F8FF)],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFD6E8FF)),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFD6E8FF),
          child: Icon(
            Icons.smart_toy_rounded,
            color: Color(0xFF1765CF),
            size: 29,
          ),
        ),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Mission Assistant',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: ink,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Real-time analysis • Actionable insights',
                style: TextStyle(color: Color(0xFF476185), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, this.onAction});
  final AIInsight insight;
  final VoidCallback? onAction;

  _InsightPresentation get _presentation =>
      _InsightPresentation.forType(insight.type);

  @override
  Widget build(BuildContext context) {
    final presentation = _presentation;
    final detail = insight.confidence == null
        ? null
        : 'Confidence: ${insight.confidence}%';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: presentation.background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: presentation.accent.withValues(alpha: .20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(presentation.icon, color: presentation.accent),
              const SizedBox(width: 9),
              Text(
                insight.label ?? '',
                style: TextStyle(
                  color: presentation.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            insight.title,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: presentation.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            insight.description,
            style: const TextStyle(color: Color(0xFF334B70)),
          ),
          if (detail != null)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                detail,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334B70),
                ),
              ),
            ),
          if (insight.actionLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.map_outlined, size: 17),
                  label: Text(insight.actionLabel!),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: presentation.accent,
                    side: BorderSide(
                      color: presentation.accent.withValues(alpha: .55),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InsightPresentation {
  const _InsightPresentation(this.icon, this.accent, this.background);
  final IconData icon;
  final Color accent;
  final Color background;

  static _InsightPresentation forType(AIInsightType type) => switch (type) {
    AIInsightType.risk => const _InsightPresentation(
      Icons.warning_amber_rounded,
      Color(0xFFD52C3E),
      Color(0xFFFFEAEC),
    ),
    AIInsightType.survivors => const _InsightPresentation(
      Icons.groups_rounded,
      Color(0xFF149C63),
      Color(0xFFE8FAF0),
    ),
    AIInsightType.route => const _InsightPresentation(
      Icons.alt_route_rounded,
      Color(0xFF1765CF),
      Color(0xFFEAF3FF),
    ),
    AIInsightType.environment => const _InsightPresentation(
      Icons.cloudy_snowing,
      Color(0xFFD79416),
      Color(0xFFFFF5DD),
    ),
    AIInsightType.recommendation => const _InsightPresentation(
      Icons.lightbulb_rounded,
      Color(0xFF7748D8),
      Color(0xFFF2EAFF),
    ),
    AIInsightType.dataSources => const _InsightPresentation(
      Icons.storage_rounded,
      Color(0xFF1765CF),
      Colors.white,
    ),
  };
}

class _DataSourcesCard extends StatelessWidget {
  const _DataSourcesCard({required this.insight});
  final AIInsight insight;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D14223B),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storage_rounded, color: Color(0xFF1765CF)),
            const SizedBox(width: 9),
            Text(
              insight.title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...insight.items.map(_DataSource.new),
      ],
    ),
  );
}

class _DataSource extends StatelessWidget {
  const _DataSource(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        const Icon(Icons.check_rounded, color: Color(0xFF18AE73), size: 19),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFF334B70))),
      ],
    ),
  );
}

class _SuggestedQuestions extends StatelessWidget {
  const _SuggestedQuestions({
    required this.questions,
    required this.onSelected,
  });
  final List<String> questions;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 39,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: questions.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) => ActionChip(
        label: Text(questions[index]),
        onPressed: () => onSelected(questions[index]),
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF174881)),
        backgroundColor: const Color(0xFFF0F6FF),
        side: const BorderSide(color: Color(0xFFC8DEFA)),
      ),
    ),
  );
}

class _AIMessageBubble extends StatelessWidget {
  const _AIMessageBubble({required this.message});
  final AIChatMessage message;
  @override
  Widget build(BuildContext context) => Align(
    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isUser) ...[
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFD6E8FF),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 19,
              color: Color(0xFF1765CF),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: message.isUser
                  ? const Color(0xFFDDEEFF)
                  : const Color(0xFFF0F3F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(message.text, style: const TextStyle(color: ink)),
          ),
        ),
      ],
    ),
  );
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) => const Padding(
    key: ValueKey('typing'),
    padding: EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFD6E8FF),
          child: Icon(
            Icons.smart_toy_rounded,
            size: 19,
            color: Color(0xFF1765CF),
          ),
        ),
        SizedBox(width: 8),
        Text(
          'AI is analyzing mission data...',
          style: TextStyle(color: Color(0xFF667085), fontSize: 12),
        ),
      ],
    ),
  );
}

class _AIComposer extends StatelessWidget {
  const _AIComposer({required this.controller, required this.onSend});
  final TextEditingController controller;
  final VoidCallback onSend;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 8,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.attach_file_rounded,
                color: Color(0xFF1765CF),
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  isDense: true,
                  suffixIcon: const Icon(Icons.mic_none_rounded),
                  filled: true,
                  fillColor: const Color(0xFFF4F7FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: const Color(0xFF2878E6),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

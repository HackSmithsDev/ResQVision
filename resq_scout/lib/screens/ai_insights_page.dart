import 'package:flutter/material.dart';

import '../widgets/backend_collection_page.dart';

class AIInsightsPage extends StatelessWidget {
  const AIInsightsPage({super.key, this.startAtChat = false});

  final bool startAtChat;

  @override
  Widget build(BuildContext context) => const BackendCollectionPage(
    title: 'AI Insights',
    subtitle: 'Insights generated and stored by backend services.',
    collection: 'ai-insights',
    icon: Icons.insights_outlined,
  );
}

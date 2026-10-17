import 'package:flutter/material.dart';

import '../widgets/backend_collection_page.dart';

class TeamCommunicationPage extends StatelessWidget {
  const TeamCommunicationPage({super.key});

  @override
  Widget build(BuildContext context) => const BackendCollectionPage(
    title: 'Team Communication',
    subtitle: 'Messages synchronized from your account.',
    collection: 'messages',
    icon: Icons.forum_outlined,
  );
}

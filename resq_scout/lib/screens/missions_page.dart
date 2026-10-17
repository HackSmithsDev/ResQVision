import 'package:flutter/material.dart';

import '../widgets/backend_collection_page.dart';

class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) => const BackendCollectionPage(
    title: 'Missions',
    subtitle: 'Mission records synchronized from your account.',
    collection: 'missions',
    icon: Icons.map_outlined,
  );
}

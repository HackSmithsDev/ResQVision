import 'package:flutter/material.dart';

import '../widgets/backend_collection_page.dart';

class RescueModeScreen extends StatelessWidget {
  const RescueModeScreen({super.key});

  @override
  Widget build(BuildContext context) => const BackendCollectionPage(
    title: 'Rescue operations',
    subtitle:
        'Emergency actions are shown only after they are recorded by backend services.',
    collection: 'emergency-actions',
    icon: Icons.sos_outlined,
  );
}

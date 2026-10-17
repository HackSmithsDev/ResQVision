import 'package:flutter/material.dart';

import '../widgets/backend_collection_page.dart';

class DroneControlPage extends StatelessWidget {
  const DroneControlPage({super.key});

  @override
  Widget build(BuildContext context) => const BackendCollectionPage(
    title: 'Fleet',
    subtitle:
        'Fleet records synchronized from your account. Flight commands are not sent by this app.',
    collection: 'drones',
    icon: Icons.flight_outlined,
  );
}

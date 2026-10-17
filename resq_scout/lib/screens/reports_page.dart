import 'package:flutter/material.dart';

import '../widgets/backend_collection_page.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) => const BackendCollectionPage(
    title: 'Reports',
    subtitle: 'Reports synchronized from your account.',
    collection: 'reports',
    icon: Icons.assignment_outlined,
  );
}

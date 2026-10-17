import 'package:flutter/material.dart';

class ManualControlPage extends StatelessWidget {
  const ManualControlPage({super.key, required this.droneId});

  final String droneId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Control · $droneId')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Flight commands are not available in this app. Use the FC-connected ELRS handset.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

class LiveFootagePage extends StatelessWidget {
  const LiveFootagePage({super.key, required this.droneId});

  final String droneId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Video · $droneId')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Mobile video is not connected. Ground-station video is handled locally by ResQ Command.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

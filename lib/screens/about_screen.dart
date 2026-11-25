import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(
        child: Text(
          '2415051028 - Jaysen Natanael Kartiko',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

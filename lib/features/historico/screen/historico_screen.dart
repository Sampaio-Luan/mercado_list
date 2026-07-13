import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: ListView(
        children: [
          const SizedBox(height: 70),
          Center(child: const Text('Em desenvolvimento ...', style: TextStyle(fontSize: 20))),
          const SizedBox(height: 70),
          Lottie.asset('lib/assets/lottie.json', fit: BoxFit.cover),
        ],
      ),
    );
  }
}

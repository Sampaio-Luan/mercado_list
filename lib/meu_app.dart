import 'package:flutter/material.dart';

import 'screens/lista_itens_screen.dart';
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  // Este widget é a raiz da sua aplicação.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const ListaItensScreen(),
    );
  }
}
import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/repositories/lista.repository.dart';
import 'meu_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR');

  runApp(
    MultiProvider(
      providers: [
        // 1. Preferências primeiro (serviço base)
        ChangeNotifierProvider(
          create: (context) => ListaRepository(),
          lazy: false,
        ),
      ],
      child: const MeuApp(),
    ),
  );
}

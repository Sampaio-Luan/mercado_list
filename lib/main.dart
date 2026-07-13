import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/preferencias_service.dart';
import 'features/preferencias_usuario/preferencias_provider.dart';
import 'meu_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR');
 final prefs = await SharedPreferences.getInstance();
  final preferenciasService = PreferenciasService(prefs);

  runApp(
    MultiProvider(
      providers: [
        // 0. Preferências primeiro (serviço base)
        ChangeNotifierProvider(
          create: (context) => PreferenciasProvider(preferenciasService)..carregar(),
          lazy: false,
        ),
        
              ],
      child: const MeuApp(),
    ),
  );
}

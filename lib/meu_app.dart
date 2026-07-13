import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'core/constants/enums/tema_app.dart';
import 'core/theme/app_theme.dart';
import 'features/preferencias_usuario/preferencias_rovider.dart';
import 'features/principal_screen.dart';

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  // Este widget é a raiz da sua aplicação.
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'pt_BR';
    final tema = context.watch<PreferenciasProvider>().preferencias.tema;
    TextTheme textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
    );
    MaterialTheme theme = MaterialTheme(textTheme);
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: tema == TemaApp.sistema
          ? theme.lightHighContrast()
          : (tema == TemaApp.claro ? theme.light() : theme.dark()),
      home: const PrincipalScreen(),
    );
  }
}

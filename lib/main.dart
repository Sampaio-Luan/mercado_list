import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/banco_local.dart';
import 'core/services/preferencias_service.dart';
import 'features/categoria/controller/categorias_controller.dart';
import 'features/categoria/mapper/categoria_mapper.dart';
import 'features/categoria/repository/categoria_repository.dart';
import 'features/categoria/service/categorias_service.dart';
import 'features/itens_recorrentes/mapper/item_recorrente_mapper.dart';
import 'features/itens_recorrentes/repository/item_recorrente_repository.dart';
import 'features/preferencias_usuario/preferencias_provider.dart';
import 'meu_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR');
  final prefs = await SharedPreferences.getInstance();
  final preferenciasService = PreferenciasService(prefs);

  final categoriasRespository = CategoriasRepository(
    bancoLocal: BancoLocal.instancia,
    categoriaMapper: CategoriaMapper(),
  );
  final itemRecorrentesRepository = ItemRecorrenteRepository(
    bancoLocal: BancoLocal.instancia,
    itemRecorrenteMapper: ItemRecorrenteMapper(),
  );

  final categoriasService = CategoriasService(
    categoriasRepository: categoriasRespository,
    itensRecorrentesRepository: itemRecorrentesRepository,
  );

  runApp(
    MultiProvider(
      providers: [
        // 0. Preferências primeiro (serviço base)
        ChangeNotifierProvider(
          create: (context) =>
              PreferenciasProvider(preferenciasService)..carregar(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) =>
              CategoriasController(categoriasService: categoriasService),
        ),
      ],
      child: const MeuApp(),
    ),
  );
}

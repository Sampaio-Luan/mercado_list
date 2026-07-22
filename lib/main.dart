import 'package:flutter/material.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/banco_local.dart';
import 'core/constants/enums/estado_de_tela.dart';
import 'core/services/preferencias_service.dart';
import 'features/categoria/controller/categorias_controller.dart';
import 'features/categoria/mapper/categoria_mapper.dart';
import 'features/categoria/repository/categoria_repository.dart';
import 'features/categoria/service/categorias_service.dart';
import 'features/categoria/service/excluir_categoria_service.dart';
import 'features/itens_recorrentes/mapper/item_recorrente_mapper.dart';
import 'features/itens_recorrentes/repository/item_recorrente_repository.dart';
import 'features/itens_recorrentes/service/item_recorrente_service.dart';
import 'features/itens/mapper/item_mapper.dart';
import 'features/itens/repository/itens_repository.dart';
import 'features/itens/service/criar_item_service.dart';
import 'features/itens/service/itens_service.dart';
import 'features/historico/repository/historico_repository.dart';
import 'features/historico/service/salvar_historico_service.dart';
import 'features/listas/controller/listas_controller.dart';
import 'features/listas/mapper/lista_mapper.dart';
import 'features/listas/repository/lista_repository.dart';
import 'features/listas/service/listas_service.dart';
import 'features/preferencias_usuario/preferencias_provider.dart';
import 'meu_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('pt_BR');
  final prefs = await SharedPreferences.getInstance();
  final preferenciasService = PreferenciasService(prefs);
  final preferenciasProvider = PreferenciasProvider(preferenciasService);
  await preferenciasProvider.carregar();

  final categoriasRepository = CategoriasRepository(
    bancoLocal: BancoLocal.instancia,
    categoriaMapper: CategoriaMapper(),
  );
  final itemRecorrentesRepository = ItemRecorrenteRepository(
    bancoLocal: BancoLocal.instancia,
    itemRecorrenteMapper: ItemRecorrenteMapper(),
  );
  final itemRecorrenteService = ItemRecorrenteService(
    itemRecorrentesRepository,
  );
  final categoriasService = CategoriasService(categoriasRepository);
  final excluirCategoriaService = ExcluirCategoriaService(
    BancoLocal.instancia,
    categoriasService,
    itemRecorrenteService,
  );
  final itensRepository = ItensRepository(
    bancoLocal: BancoLocal.instancia,
    itemMapper: ItemMapper(),
  );
  final itensService = ItensService(itensRepository);
  final criarItemService = CriarItemService(
    BancoLocal.instancia,
    itensRepository,
    itemRecorrentesRepository,
  );
  final salvarHistoricoService = SalvarHistoricoService(
    HistoricoRepository(BancoLocal.instancia),
  );
  final listaRepository = ListaRepository(
    bancoLocal: BancoLocal.instancia,
    listaMapper: ListaMapper(),
  );
  final listasService = ListasService(
    listaRepository,
    itensService,
    BancoLocal.instancia,
  );

  runApp(
    MultiProvider(
      providers: [
        // 0. Preferências primeiro (serviço base)
        ChangeNotifierProvider.value(value: preferenciasProvider),
        ChangeNotifierProvider(
          create: (context) => CategoriasController(
            categoriasService,
            itemRecorrenteService,
            excluirCategoriaService,
          )..carregar(),
          lazy: false,
        ),
        ChangeNotifierProxyProvider<CategoriasController, ListasController>(
          create: (context) => ListasController(
            listasService,
            itensService,
            preferenciasProvider,
            categoriasService: categoriasService,
            itemRecorrenteService: itemRecorrenteService,
            criarItemService: criarItemService,
            salvarHistoricoService: salvarHistoricoService,
            aoSincronizarItensRecorrentes: context
                .read<CategoriasController>()
                .sincronizarItensRecorrentes,
          )..carregar(),
          update: (context, categoriasController, listasController) {
            final controller = listasController!;
            if (categoriasController.estado == EstadoDeTela.carregadaComDados ||
                categoriasController.estado == EstadoDeTela.carregadaSemDados) {
              controller.sincronizarCategorias(
                categoriasController.categoriasComItensRecorrentes.map(
                  (grupo) => grupo.categoria,
                ),
              );
              controller.sincronizarItensRecorrentes(
                categoriasController.categoriasComItensRecorrentes.expand(
                  (grupo) => grupo.itensRecorrentes,
                ),
              );
            }
            return controller;
          },
          lazy: false,
        ),
      ],
      child: const MeuApp(),
    ),
  );
}

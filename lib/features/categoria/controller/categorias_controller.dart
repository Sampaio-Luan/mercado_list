import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/logs/logs.dart';
import '../../../core/database/banco_local.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/service/item_recorrente_service.dart';
import '../model/categoria_com_itens_recorrentes_model.dart';
import '../model/categoria_model.dart';
import '../service/categorias_service.dart';

class CategoriasController extends ChangeNotifier {
  final BancoLocal _bancoLocal;
  final CategoriasService _categoriasService;
  final ItemRecorrenteService _itemRecorrenteService;
  final List<CategoriaComItensRecorrentes> _categoriasComItensRecorrentes = [];

  late final UnmodifiableListView<CategoriaComItensRecorrentes>
      _categoriasSomenteLeitura = UnmodifiableListView(
    _categoriasComItensRecorrentes,
  );

  CategoriasController(
    this._bancoLocal,
    this._categoriasService,
    this._itemRecorrenteService,
  );

  EstadoDeTela estado = EstadoDeTela.carregando;

  List<CategoriaComItensRecorrentes> get categoriasComItensRecorrentes =>
      _categoriasSomenteLeitura;

  Future<void> carregar() async {
    _alterarEstado(EstadoDeTela.carregando);

    try {
      final categorias = await _categoriasService.recuperarTodos();
      final itensRecorrentes = await _itemRecorrenteService.recuperarTodos();
      _agruparCategorias(categorias, itensRecorrentes);
      _alterarEstado(
        categorias.isEmpty
            ? EstadoDeTela.carregadaSemDados
            : EstadoDeTela.carregadaComDados,
      );
    } catch (erro, stackTrace) {
      _registrarErro('carregar', erro, stackTrace);
      _alterarEstado(EstadoDeTela.erro);
    }
  }

  Future<void> reordenar(int indiceAntigo, int indiceNovo) async {
    final indiceDestino =
        indiceAntigo < indiceNovo ? indiceNovo - 1 : indiceNovo;
    final categoriaMovida = _categoriasComItensRecorrentes.removeAt(
      indiceAntigo,
    );
    _categoriasComItensRecorrentes.insert(indiceDestino, categoriaMovida);
    _atualizarOrdensEmMemoria();
    notifyListeners();

    try {
      await _categoriasService.atualizarOrdens(
        _categoriasComItensRecorrentes.map((item) => item.categoria).toList(),
      );
    } catch (erro, stackTrace) {
      _categoriasComItensRecorrentes.removeAt(indiceDestino);
      _categoriasComItensRecorrentes.insert(indiceAntigo, categoriaMovida);
      _atualizarOrdensEmMemoria();
      notifyListeners();
      _registrarErro('reordenar', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluir(
    Categoria categoria, {
    void Function(int etapa, int total, String descricao)? aoProgredir,
  }) async {
    final categoriaOrigem = _buscarCategoriaEmMemoria(categoria.id);
    final categoriaPadraoEmMemoria = _buscarCategoriaPadraoEmMemoria();

    try {
      await _bancoLocal.executarEmTransacao((transaction) async {
        _informarProgresso(
          aoProgredir,
          1,
          'Localizando a categoria padrão...',
        );
        final categoriaPadrao = await _categoriasService.prepararExclusao(
          categoria,
          databaseExecutor: transaction,
        );
        _validarCategoriaPadraoEmMemoria(
          categoriaPadraoEmMemoria,
          categoriaPadrao,
        );

        _informarProgresso(
          aoProgredir,
          2,
          'Buscando os itens recorrentes...',
        );
        final itens = await _itemRecorrenteService.buscarPorCategoria(
          idCategoria: categoria.id!,
          databaseExecutor: transaction,
        );

        _informarProgresso(
          aoProgredir,
          3,
          _descricaoMovimentacao(itens.length),
        );
        await _itemRecorrenteService.moverParaCategoria(
          itens: itens,
          categoriaOrigem: categoria.id!,
          categoriaDestino: categoriaPadrao.id!,
          databaseExecutor: transaction,
        );

        _informarProgresso(aoProgredir, 4, 'Excluindo a categoria...');
        await _categoriasService.excluir(
          categoria,
          databaseExecutor: transaction,
        );
      });

      _informarProgresso(
        aoProgredir,
        5,
        'Atualizando a lista de categorias...',
      );
      _moverItensEmMemoria(categoriaOrigem, categoriaPadraoEmMemoria);
      _categoriasComItensRecorrentes.remove(categoriaOrigem);
      notifyListeners();
    } catch (erro, stackTrace) {
      _registrarErro('excluir', erro, stackTrace);
      rethrow;
    }
  }

  void _agruparCategorias(
    List<Categoria> categorias,
    List<ItemRecorrente> itensRecorrentes,
  ) {
    final itensPorCategoria = <int, List<ItemRecorrente>>{};
    for (final item in itensRecorrentes) {
      itensPorCategoria.putIfAbsent(item.idCategoria, () => []).add(item);
    }

    _categoriasComItensRecorrentes
      ..clear()
      ..addAll(
        categorias.map(
          (categoria) => CategoriaComItensRecorrentes(
            categoria: categoria,
            itensRecorrentes: itensPorCategoria[categoria.id] ?? [],
          ),
        ),
      );
  }

  CategoriaComItensRecorrentes _buscarCategoriaEmMemoria(int? idCategoria) {
    return _categoriasComItensRecorrentes.firstWhere(
      (item) => item.categoria.id == idCategoria,
      orElse: () => throw StateError(
        'Categoria $idCategoria não encontrada no estado em memória.',
      ),
    );
  }

  CategoriaComItensRecorrentes _buscarCategoriaPadraoEmMemoria() {
    return _categoriasComItensRecorrentes.firstWhere(
      (item) => item.categoria.categoriaPadrao,
      orElse: () => throw StateError(
        'Categoria padrão não encontrada no estado em memória.',
      ),
    );
  }

  void _validarCategoriaPadraoEmMemoria(
    CategoriaComItensRecorrentes categoriaEmMemoria,
    Categoria categoriaPersistida,
  ) {
    if (categoriaEmMemoria.categoria.id != categoriaPersistida.id) {
      throw StateError('A categoria padrão em memória está desatualizada.');
    }
  }

  void _moverItensEmMemoria(
    CategoriaComItensRecorrentes categoriaOrigem,
    CategoriaComItensRecorrentes categoriaDestino,
  ) {
    final agora = DateTime.now();
    final itens = categoriaOrigem.itensRecorrentes;

    for (final item in itens) {
      item
        ..idCategoria = categoriaDestino.categoria.id!
        ..dataAlteracao = agora;
    }

    categoriaDestino.itensRecorrentes.addAll(itens);
    itens.clear();
  }

  void _atualizarOrdensEmMemoria() {
    final agora = DateTime.now();
    for (var indice = 0;
        indice < _categoriasComItensRecorrentes.length;
        indice++) {
      _categoriasComItensRecorrentes[indice].categoria
        ..ordem = indice + 1
        ..dtEdicao = agora;
    }
  }

  void _informarProgresso(
    void Function(int etapa, int total, String descricao)? aoProgredir,
    int etapa,
    String descricao,
  ) {
    aoProgredir?.call(etapa, 5, descricao);
  }

  String _descricaoMovimentacao(int quantidade) {
    if (quantidade == 0) {
      return 'Nenhum item recorrente precisa ser movido.';
    }
    if (quantidade == 1) {
      return 'Movendo 1 item recorrente...';
    }
    return 'Movendo $quantidade itens recorrentes...';
  }

  void _alterarEstado(EstadoDeTela novoEstado) {
    estado = novoEstado;
    notifyListeners();
  }

  void _registrarErro(
    String operacao,
    Object erro,
    StackTrace stackTrace,
  ) {
    log(
      '$operacao(): $erro',
      name: LogId.categoriasController,
      error: erro,
      stackTrace: stackTrace,
    );
  }
}

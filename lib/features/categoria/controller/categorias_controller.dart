import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/logs/logs.dart';
import '../../../core/model/progresso_operacao.dart';
import '../../../core/utils/texto_utils.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/service/item_recorrente_service.dart';
import '../model/categoria_com_itens_recorrentes_model.dart';
import '../model/categoria_model.dart';
import '../service/categorias_service.dart';
import '../service/excluir_categoria_service.dart';

class CategoriasController extends ChangeNotifier {
  final CategoriasServiceContract _categoriasService;
  final ItemRecorrenteService _itemRecorrenteService;
  final ExcluirCategoriaContract _excluirCategoriaService;
  final List<CategoriaComItensRecorrentes> _categoriasComItensRecorrentes = [];

  late final UnmodifiableListView<CategoriaComItensRecorrentes>
      _categoriasSomenteLeitura = UnmodifiableListView(
    _categoriasComItensRecorrentes,
  );

  CategoriasController(
    this._categoriasService,
    this._itemRecorrenteService,
    this._excluirCategoriaService,
  );

  EstadoDeTela estado = EstadoDeTela.carregando;
  String? mensagemErro;
  bool _alterandoOrdem = false;

  bool get alterandoOrdem => _alterandoOrdem;

  List<CategoriaComItensRecorrentes> get categoriasComItensRecorrentes =>
      _categoriasSomenteLeitura;

  Future<void> carregar() async {
    mensagemErro = null;
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
      mensagemErro = 'Não foi possível carregar as categorias.';
      _registrarErro('carregar', erro, stackTrace);
      _alterarEstado(EstadoDeTela.erro);
    }
  }

  Future<void> reordenar(int indiceAntigo, int indiceNovo) async {
    _iniciarAlteracaoDeOrdem();
    CategoriaComItensRecorrentes? categoriaMovida;
    var indiceDestino = indiceNovo;

    try {
      // `onReorderItem` já entrega o índice corrigido após a remoção do item.
      categoriaMovida = _categoriasComItensRecorrentes.removeAt(indiceAntigo);
      _categoriasComItensRecorrentes.insert(indiceDestino, categoriaMovida);
      _atualizarOrdensEmMemoria();
      notifyListeners();

      await _categoriasService.atualizarOrdens(
        _categoriasComItensRecorrentes.map((item) => item.categoria).toList(),
      );
    } catch (erro, stackTrace) {
      if (categoriaMovida != null) {
        indiceDestino = _categoriasComItensRecorrentes.indexOf(categoriaMovida);
        if (indiceDestino >= 0) {
          _categoriasComItensRecorrentes.removeAt(indiceDestino);
          _categoriasComItensRecorrentes.insert(
            indiceAntigo,
            categoriaMovida,
          );
          _atualizarOrdensEmMemoria();
          notifyListeners();
        }
      }
      _registrarErro('reordenar', erro, stackTrace);
      rethrow;
    } finally {
      _finalizarAlteracaoDeOrdem();
    }
  }

  Future<void> ordenarAlfabeticamente() async {
    _iniciarAlteracaoDeOrdem();
    final ordemAnterior = List.of(_categoriasComItensRecorrentes);

    try {
      _categoriasComItensRecorrentes.sort((primeiro, segundo) {
        final tituloPrimeiro = TextoUtils.normalizarParaOrdenacao(
          primeiro.categoria.titulo,
        );
        final tituloSegundo = TextoUtils.normalizarParaOrdenacao(
          segundo.categoria.titulo,
        );
        final comparacaoTitulo = tituloPrimeiro.compareTo(tituloSegundo);
        if (comparacaoTitulo != 0) return comparacaoTitulo;
        return (primeiro.categoria.id ?? 0).compareTo(
          segundo.categoria.id ?? 0,
        );
      });
      _atualizarOrdensEmMemoria();
      notifyListeners();

      await _categoriasService.atualizarOrdens(
        _categoriasComItensRecorrentes.map((item) => item.categoria).toList(),
      );
    } catch (erro, stackTrace) {
      _categoriasComItensRecorrentes
        ..clear()
        ..addAll(ordemAnterior);
      _atualizarOrdensEmMemoria();
      notifyListeners();
      _registrarErro('ordenarAlfabeticamente', erro, stackTrace);
      rethrow;
    } finally {
      _finalizarAlteracaoDeOrdem();
    }
  }

  Future<Categoria> criarCategoria(Categoria categoria) async {
    _validarSemAlteracaoDeOrdem();
    _registrarInicio('criarCategoria', 'titulo=${categoria.titulo}');
    try {
      categoria.ordem = _categoriasComItensRecorrentes.length + 1;
      final categoriaCriada = await _categoriasService.criar(categoria);
      _categoriasComItensRecorrentes.add(
        CategoriaComItensRecorrentes(
          categoria: categoriaCriada,
          itensRecorrentes: [],
        ),
      );
      _alterarEstado(EstadoDeTela.carregadaComDados);
      _registrarSucesso('criarCategoria', 'categoria=${categoriaCriada.id}');
      return categoriaCriada;
    } catch (erro, stackTrace) {
      _registrarErro('criarCategoria', erro, stackTrace);
      rethrow;
    }
  }

  Future<Categoria> editarCategoria(Categoria categoria) async {
    _validarSemAlteracaoDeOrdem();
    _registrarInicio('editarCategoria', 'categoria=${categoria.id}');
    try {
      final indice = _categoriasComItensRecorrentes.indexWhere(
        (grupo) => grupo.categoria.id == categoria.id,
      );
      if (indice < 0) {
        throw StateError(
          'Categoria ${categoria.id} não encontrada no estado em memória.',
        );
      }
      final categoriaEditada = await _categoriasService.editar(categoria);
      final grupoAnterior = _categoriasComItensRecorrentes[indice];
      _categoriasComItensRecorrentes[indice] = CategoriaComItensRecorrentes(
        categoria: categoriaEditada,
        itensRecorrentes: grupoAnterior.itensRecorrentes,
      );
      notifyListeners();
      _registrarSucesso(
        'editarCategoria',
        'categoria=${categoriaEditada.id}',
      );
      return categoriaEditada;
    } catch (erro, stackTrace) {
      _registrarErro('editarCategoria', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluir(
    Categoria categoria, {
    AoProgredir? aoProgredir,
  }) async {
    _validarSemAlteracaoDeOrdem();
    final categoriaOrigem = _buscarCategoriaEmMemoria(categoria.id);
    final categoriaPadraoEmMemoria = _buscarCategoriaPadraoEmMemoria();

    try {
      final resultado = await _excluirCategoriaService.executar(
        categoria,
        idCategoriaPadraoEsperada: categoriaPadraoEmMemoria.categoria.id!,
        aoProgredir: aoProgredir,
      );

      _informarProgresso(
        aoProgredir,
        5,
        'Atualizando a lista de categorias...',
      );
      _moverItensEmMemoria(
        categoriaOrigem,
        categoriaPadraoEmMemoria,
        resultado.dataAlteracao,
      );
      _categoriasComItensRecorrentes.remove(categoriaOrigem);
      notifyListeners();
    } catch (erro, stackTrace) {
      _registrarErro('excluir', erro, stackTrace);
      rethrow;
    }
  }

  Future<ItemRecorrente> adicionarItemRecorrente(
    ItemRecorrente item,
  ) async {
    _registrarInicio(
      'adicionarItemRecorrente',
      'categoria=${item.idCategoria}, titulo=${item.titulo}',
    );
    try {
      final itemCriado = await _itemRecorrenteService.criar(item);
      _buscarCategoriaEmMemoria(
        itemCriado.idCategoria,
      ).itensRecorrentes.add(itemCriado);
      notifyListeners();
      _registrarSucesso(
        'adicionarItemRecorrente',
        'item=${itemCriado.id}, categoria=${itemCriado.idCategoria}',
      );
      return itemCriado;
    } catch (erro, stackTrace) {
      _registrarErro('adicionarItemRecorrente', erro, stackTrace);
      rethrow;
    }
  }

  Future<ItemRecorrente> editarItemRecorrente(
    ItemRecorrente item,
  ) async {
    _registrarInicio('editarItemRecorrente', 'item=${item.id}');
    try {
      final itemEditado = await _itemRecorrenteService.editar(item);
      final localizacao = _buscarItemEmMemoria(itemEditado.id!);
      localizacao.itensRecorrentes[localizacao.indiceItem] = itemEditado;
      notifyListeners();
      _registrarSucesso('editarItemRecorrente', 'item=${itemEditado.id}');
      return itemEditado;
    } catch (erro, stackTrace) {
      _registrarErro('editarItemRecorrente', erro, stackTrace);
      rethrow;
    }
  }

  Future<ItemRecorrente> moverItemRecorrente(
    ItemRecorrente item,
    int idCategoriaDestino,
  ) async {
    _registrarInicio(
      'moverItemRecorrente',
      'item=${item.id}, origem=${item.idCategoria}, '
          'destino=$idCategoriaDestino',
    );
    try {
      final itemMovido = await _itemRecorrenteService.moverItemParaCategoria(
        item: item,
        idCategoriaDestino: idCategoriaDestino,
      );
      final origem = _buscarItemEmMemoria(item.id!);
      origem.itensRecorrentes.removeAt(origem.indiceItem);
      _buscarCategoriaEmMemoria(
        idCategoriaDestino,
      ).itensRecorrentes.add(itemMovido);
      notifyListeners();
      _registrarSucesso(
        'moverItemRecorrente',
        'item=${itemMovido.id}, destino=$idCategoriaDestino',
      );
      return itemMovido;
    } catch (erro, stackTrace) {
      _registrarErro('moverItemRecorrente', erro, stackTrace);
      rethrow;
    }
  }

  Future<List<ItemRecorrente>> moverItensRecorrentes(
    List<ItemRecorrente> itens,
    int idCategoriaDestino,
  ) async {
    _registrarInicio(
      'moverItensRecorrentes',
      'quantidade=${itens.length}, destino=$idCategoriaDestino',
    );
    try {
      final itensMovidos = await _itemRecorrenteService.moverItensParaCategoria(
        itens: itens,
        idCategoriaDestino: idCategoriaDestino,
      );
      final idsMovidos = itensMovidos.map((item) => item.id).toSet();
      for (final grupo in _categoriasComItensRecorrentes) {
        grupo.itensRecorrentes.removeWhere(
          (item) => idsMovidos.contains(item.id),
        );
      }
      _buscarCategoriaEmMemoria(
        idCategoriaDestino,
      ).itensRecorrentes.addAll(itensMovidos);
      notifyListeners();
      _registrarSucesso(
        'moverItensRecorrentes',
        'quantidade=${itensMovidos.length}, destino=$idCategoriaDestino',
      );
      return itensMovidos;
    } catch (erro, stackTrace) {
      _registrarErro('moverItensRecorrentes', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluirItemRecorrente(ItemRecorrente item) async {
    _registrarInicio('excluirItemRecorrente', 'item=${item.id}');
    try {
      if (item.id == null) {
        throw StateError('O item precisa estar persistido.');
      }
      await _itemRecorrenteService.excluir(item.id!);
      final localizacao = _buscarItemEmMemoria(item.id!);
      localizacao.itensRecorrentes.removeAt(localizacao.indiceItem);
      notifyListeners();
      _registrarSucesso('excluirItemRecorrente', 'item=${item.id}');
    } catch (erro, stackTrace) {
      _registrarErro('excluirItemRecorrente', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluirItensRecorrentes(List<ItemRecorrente> itens) async {
    _registrarInicio(
      'excluirItensRecorrentes',
      'quantidade=${itens.length}',
    );
    try {
      await _itemRecorrenteService.excluirItens(itens);
      final idsExcluidos = itens.map((item) => item.id).toSet();
      for (final grupo in _categoriasComItensRecorrentes) {
        grupo.itensRecorrentes.removeWhere(
          (item) => idsExcluidos.contains(item.id),
        );
      }
      notifyListeners();
      _registrarSucesso(
        'excluirItensRecorrentes',
        'quantidade=${itens.length}',
      );
    } catch (erro, stackTrace) {
      _registrarErro('excluirItensRecorrentes', erro, stackTrace);
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

  _LocalizacaoItem _buscarItemEmMemoria(int idItem) {
    for (final categoria in _categoriasComItensRecorrentes) {
      final indice = categoria.itensRecorrentes.indexWhere(
        (item) => item.id == idItem,
      );
      if (indice >= 0) {
        return _LocalizacaoItem(categoria.itensRecorrentes, indice);
      }
    }
    throw StateError('Item recorrente $idItem não encontrado em memória.');
  }

  void _moverItensEmMemoria(
    CategoriaComItensRecorrentes categoriaOrigem,
    CategoriaComItensRecorrentes categoriaDestino,
    DateTime dataAlteracao,
  ) {
    final itens = categoriaOrigem.itensRecorrentes;

    for (final item in itens) {
      item
        ..idCategoria = categoriaDestino.categoria.id!
        ..dataAlteracao = dataAlteracao;
    }

    categoriaDestino.itensRecorrentes.addAll(itens);
    itens.clear();
  }

  void _atualizarOrdensEmMemoria() {
    for (var indice = 0;
        indice < _categoriasComItensRecorrentes.length;
        indice++) {
      _categoriasComItensRecorrentes[indice].categoria.ordem = indice + 1;
    }
  }

  void _iniciarAlteracaoDeOrdem() {
    if (_alterandoOrdem) {
      throw StateError('Já existe uma alteração de ordem em andamento.');
    }
    _alterandoOrdem = true;
  }

  void _validarSemAlteracaoDeOrdem() {
    if (_alterandoOrdem) {
      throw StateError(
        'Aguarde a conclusão da alteração de ordem das categorias.',
      );
    }
  }

  void _finalizarAlteracaoDeOrdem() {
    _alterandoOrdem = false;
    notifyListeners();
  }

  void _informarProgresso(
    AoProgredir? aoProgredir,
    int etapa,
    String descricao,
  ) {
    aoProgredir?.call(
      ProgressoOperacao(etapa: etapa, total: 5, descricao: descricao),
    );
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

  void _registrarInicio(String operacao, String detalhes) {
    log(
      '$operacao(): iniciando; $detalhes',
      name: LogId.categoriasController,
    );
  }

  void _registrarSucesso(String operacao, String detalhes) {
    log(
      '$operacao(): concluído com sucesso; $detalhes',
      name: LogId.categoriasController,
    );
  }
}

class _LocalizacaoItem {
  final List<ItemRecorrente> itensRecorrentes;
  final int indiceItem;

  const _LocalizacaoItem(this.itensRecorrentes, this.indiceItem);
}

import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
import '../../../core/constants/enums/tipo_visualizacao_itens.dart';
import '../../../core/constants/logs/logs.dart';
import '../../../core/utils/texto_utils.dart';
import '../../../shared/widgets/painel_pesquisa/similaridade_texto.dart';
import '../../categoria/model/categoria_model.dart';
import '../../categoria/service/categorias_service.dart';
import '../../historico/model/historico_model.dart';
import '../../historico/service/salvar_historico_service.dart';
import '../../itens/model/categoria_com_itens_model.dart';
import '../../itens/model/filtro_itens.dart';
import '../../itens/model/item_model.dart';
import '../../itens/model/resumo_financeiro_itens.dart';
import '../../itens/model/sugestao_item_recorrente.dart';
import '../../itens/service/criar_item_service.dart';
import '../../itens/service/itens_service.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/service/item_recorrente_service.dart';
import '../../preferencias_usuario/preferencias_provider.dart';
import '../model/lista_com_resumo_de_itens_model.dart';
import '../model/lista_model.dart';
import '../service/listas_service.dart';

class ListasController extends ChangeNotifier {
  final ListasServiceContract _listasService;
  final ItensService _itensService;
  final PreferenciasProvider _preferencias;
  final CategoriasServiceContract? _categoriasService;
  final ItemRecorrenteService? _itemRecorrenteService;
  final CriarItemService? _criarItemService;
  final SalvarHistoricoService? _salvarHistoricoService;
  final ValueChanged<List<ItemRecorrente>>? _aoSincronizarItensRecorrentes;
  final List<ListaComResumoDeItens> _listas = [];
  final List<Item> _itens = [];
  final List<Categoria> _categorias = [];
  final List<ItemRecorrente> _itensRecorrentes = [];

  ListasController(
    this._listasService,
    this._itensService,
    this._preferencias, {
    CategoriasServiceContract? categoriasService,
    ItemRecorrenteService? itemRecorrenteService,
    CriarItemService? criarItemService,
    SalvarHistoricoService? salvarHistoricoService,
    ValueChanged<List<ItemRecorrente>>? aoSincronizarItensRecorrentes,
    // ignore: prefer_initializing_formals
  })  : _categoriasService = categoriasService,
        // ignore: prefer_initializing_formals
        _itemRecorrenteService = itemRecorrenteService,
        // ignore: prefer_initializing_formals
        _criarItemService = criarItemService,
        // ignore: prefer_initializing_formals
        _salvarHistoricoService = salvarHistoricoService,
        // ignore: prefer_initializing_formals
        _aoSincronizarItensRecorrentes = aoSincronizarItensRecorrentes;

  EstadoDeTela estado = EstadoDeTela.carregando;
  EstadoDeTela estadoItens = EstadoDeTela.carregando;
  String? mensagemErro;
  int? _idListaSelecionada;
  int _versaoCarregamentoItens = 0;
  bool alterandoOrdem = false;
  FiltroItens filtroItens = const FiltroItens();
  OrdenarPor ordenarItensPor = OrdenarPor.nome;
  Ordem ordemItens = Ordem.ascendente;
  String pesquisaItens = '';

  UnmodifiableListView<ListaComResumoDeItens> get listas =>
      UnmodifiableListView(_listas);
  UnmodifiableListView<Item> get itens => UnmodifiableListView(_itens);
  UnmodifiableListView<Categoria> get categorias =>
      UnmodifiableListView(_categorias);
  UnmodifiableListView<ItemRecorrente> get itensRecorrentes =>
      UnmodifiableListView(_itensRecorrentes);
  int? get idListaSelecionada => _idListaSelecionada;

  Lista? get listaSelecionada {
    for (final resumo in _listas) {
      if (resumo.lista.id == _idListaSelecionada) return resumo.lista;
    }
    return null;
  }

  TipoVisualizacaoItens get tipoVisualizacaoItens =>
      _preferencias.preferencias.tipoVisualizacao;

  ResumoFinanceiroItens get resumoFinanceiro =>
      ResumoFinanceiroItens.calcular(_itens);

  bool get possuiItens => _itens.isNotEmpty;
  bool get possuiItensMarcados => _itens.any((item) => item.obtido);

  List<Item> get itensVisiveis {
    final termo = TextoUtils.normalizarParaOrdenacao(pesquisaItens);
    final resultado = _itens.where((item) {
      if (filtroItens.situacao == SituacaoItem.pendentes && item.obtido) {
        return false;
      }
      if (filtroItens.situacao == SituacaoItem.marcados && !item.obtido) {
        return false;
      }
      if (filtroItens.idCategoria != null &&
          item.idCategoria != filtroItens.idCategoria) {
        return false;
      }
      if (filtroItens.prioridade != null &&
          item.prioridade != filtroItens.prioridade) {
        return false;
      }
      if (filtroItens.possuiPreco != null &&
          (item.preco != null) != filtroItens.possuiPreco) {
        return false;
      }
      return termo.isEmpty ||
          TextoUtils.normalizarParaOrdenacao(item.titulo).contains(termo);
    }).toList();
    resultado.sort(_compararItens);
    return List.unmodifiable(resultado);
  }

  List<CategoriaComItens> get categoriasComItens {
    final porCategoria = <int, List<Item>>{};
    for (final item in itensVisiveis) {
      porCategoria.putIfAbsent(item.idCategoria, () => []).add(item);
    }
    final grupos = <CategoriaComItens>[];
    for (final categoria in _categorias) {
      final itens = porCategoria.remove(categoria.id);
      if (itens != null && itens.isNotEmpty) {
        grupos.add(CategoriaComItens(categoria: categoria, itens: itens));
      }
    }
    // Garante exibição mesmo quando uma categoria foi removida do estado.
    for (final entrada in porCategoria.entries) {
      grupos.add(CategoriaComItens(
        categoria: Categoria(
          id: entrada.key,
          titulo: 'Sem categoria',
          cor: listaSelecionada?.cor ?? const Color(0xFF795548),
          ordem: 9999,
          categoriaPadrao: true,
        ),
        itens: entrada.value,
      ));
    }
    return List.unmodifiable(grupos);
  }

  List<SugestaoItemRecorrente> sugerirItens(String termo) {
    if (termo.trim().isEmpty) return const [];
    final categoriasPorId = {
      for (final categoria in _categorias) categoria.id!: categoria,
    };
    final sugestoes = <SugestaoItemRecorrente>[];
    for (final recorrente in _itensRecorrentes) {
      final categoria = categoriasPorId[recorrente.idCategoria];
      if (categoria == null) continue;
      final relevancia = SimilaridadeTexto.calcularPontuacaoRelevancia(
        textoItem: recorrente.titulo,
        textoPesquisa: termo,
      );
      if (relevancia > 0) {
        sugestoes.add(SugestaoItemRecorrente(
          item: recorrente,
          categoria: categoria,
          relevancia: relevancia,
        ));
      }
    }
    sugestoes.sort((a, b) => b.relevancia.compareTo(a.relevancia));
    return List.unmodifiable(sugestoes.take(4));
  }

  Item? localizarDuplicado(String titulo) {
    final normalizado = TextoUtils.normalizarParaOrdenacao(titulo);
    for (final item in _itens) {
      if (TextoUtils.normalizarParaOrdenacao(item.titulo) == normalizado) {
        return item;
      }
    }
    return null;
  }

  List<ListaComResumoDeItens> pesquisar(String termo) {
    final normalizado = TextoUtils.normalizarParaOrdenacao(termo.trim());
    if (normalizado.isEmpty) return List.unmodifiable(_listas);
    return _listas.where((resumo) {
      return TextoUtils.normalizarParaOrdenacao(resumo.lista.titulo)
          .contains(normalizado);
    }).toList(growable: false);
  }

  Future<void> carregar() async {
    _registrarInicio('carregar', 'listas e dados auxiliares');
    mensagemErro = null;
    estado = EstadoDeTela.carregando;
    notifyListeners();
    try {
      await _recarregarResumos();
      await _carregarDadosAuxiliares();
      final preferida = _preferencias.preferencias.ultimaListaAberta;
      final existePreferida =
          _listas.any((resumo) => resumo.lista.id == preferida);
      final resolvida = existePreferida
          ? preferida
          : (_listas.isEmpty ? null : _listas.first.lista.id);
      estado = _listas.isEmpty
          ? EstadoDeTela.carregadaSemDados
          : EstadoDeTela.carregadaComDados;
      await _selecionarResolvida(resolvida, salvar: resolvida != preferida);
      _registrarSucesso(
        'carregar',
        'listas=${_listas.length}, listaSelecionada=$_idListaSelecionada',
      );
    } catch (erro, stackTrace) {
      mensagemErro = 'Não foi possível carregar as listas.';
      estado = EstadoDeTela.erro;
      estadoItens = EstadoDeTela.erro;
      _registrarErro('carregar', erro, stackTrace);
      notifyListeners();
    }
  }

  void sincronizarCategorias(Iterable<Categoria> categorias) {
    final atualizadas =
        categorias.map((categoria) => categoria.copia()).toList()
          ..sort((primeira, segunda) {
            final porOrdem = primeira.ordem.compareTo(segunda.ordem);
            return porOrdem != 0
                ? porOrdem
                : (primeira.id ?? 0).compareTo(segunda.id ?? 0);
          });
    if (_categoriasIguais(_categorias, atualizadas)) return;
    _categorias
      ..clear()
      ..addAll(atualizadas);
    _registrarSucesso(
      'sincronizarCategorias',
      'categorias=${_categorias.length}',
    );
    notifyListeners();
  }

  void sincronizarItensRecorrentes(Iterable<ItemRecorrente> itens) {
    final atualizados = itens.map((item) => item.copia()).toList();
    if (_itensRecorrentesIguais(_itensRecorrentes, atualizados)) return;
    _itensRecorrentes
      ..clear()
      ..addAll(atualizados);
    _registrarSucesso(
      'sincronizarItensRecorrentes',
      'itens=${_itensRecorrentes.length}',
    );
    notifyListeners();
  }

  Future<void> selecionar(int idLista) async {
    if (_idListaSelecionada == idLista && estadoItens != EstadoDeTela.erro) {
      return;
    }
    if (!_listas.any((resumo) => resumo.lista.id == idLista)) {
      throw StateError('A lista selecionada não está disponível.');
    }
    await _selecionarResolvida(idLista, salvar: true);
  }

  Future<Lista> criar(Lista lista) async {
    final criada = await _listasService.criar(lista);
    await _recarregarResumos();
    estado = EstadoDeTela.carregadaComDados;
    await _selecionarResolvida(criada.id, salvar: true);
    return criada;
  }

  Future<Lista> editar(Lista lista) async {
    final editada = await _listasService.editar(lista);
    await _recarregarResumos();
    notifyListeners();
    return editada;
  }

  Future<void> alternarFixacao(Lista lista) async {
    final alterada = lista.copia()..fixada = !lista.fixada;
    await editar(alterada);
  }

  Future<Lista> copiar(Lista lista) async {
    final copia = await _listasService.copiar(lista);
    await _recarregarResumos();
    estado = EstadoDeTela.carregadaComDados;
    await _selecionarResolvida(copia.id, salvar: true);
    return copia;
  }

  Future<void> excluir(Lista lista) async {
    final indice = _listas.indexWhere((resumo) => resumo.lista.id == lista.id);
    final eraSelecionada = lista.id == _idListaSelecionada;
    await _listasService.excluir(lista);
    await _recarregarResumos();
    estado = _listas.isEmpty
        ? EstadoDeTela.carregadaSemDados
        : EstadoDeTela.carregadaComDados;
    if (eraSelecionada) {
      final proximoIndice =
          _listas.isEmpty ? -1 : indice.clamp(0, _listas.length - 1);
      final proximo =
          proximoIndice < 0 ? null : _listas[proximoIndice].lista.id;
      await _selecionarResolvida(proximo, salvar: true);
    } else {
      notifyListeners();
    }
  }

  Future<void> reordenar(int indiceAntigo, int indiceNovo) async {
    if (alterandoOrdem || indiceAntigo == indiceNovo) return;
    final movida = _listas[indiceAntigo];
    if (_listas[indiceNovo].lista.fixada != movida.lista.fixada) {
      throw StateError('Listas fixadas só podem ser ordenadas entre si.');
    }
    alterandoOrdem = true;
    final anterior = List<ListaComResumoDeItens>.of(_listas);
    _listas
      ..removeAt(indiceAntigo)
      ..insert(indiceNovo, movida);
    notifyListeners();
    try {
      await _listasService.atualizarOrdens(
        _listas.map((resumo) => resumo.lista).toList(),
      );
    } catch (_) {
      _listas
        ..clear()
        ..addAll(anterior);
      rethrow;
    } finally {
      alterandoOrdem = false;
      notifyListeners();
    }
  }

  Future<void> ordenarAlfabeticamente() async {
    if (alterandoOrdem) return;
    alterandoOrdem = true;
    final anterior = List<ListaComResumoDeItens>.of(_listas);
    _listas.sort((a, b) {
      if (a.lista.fixada != b.lista.fixada) return a.lista.fixada ? -1 : 1;
      final tituloA = TextoUtils.normalizarParaOrdenacao(a.lista.titulo);
      final tituloB = TextoUtils.normalizarParaOrdenacao(b.lista.titulo);
      return tituloA.compareTo(tituloB);
    });
    notifyListeners();
    try {
      await _listasService.atualizarOrdens(
        _listas.map((resumo) => resumo.lista).toList(),
      );
    } catch (_) {
      _listas
        ..clear()
        ..addAll(anterior);
      notifyListeners();
      rethrow;
    } finally {
      alterandoOrdem = false;
      notifyListeners();
    }
  }

  Future<void> alterarObtido(Item item, bool obtido) async {
    _registrarInicio(
      'alterarObtido',
      'item=${item.id}, obtido=$obtido',
    );
    final indice = _itens.indexWhere((existente) => existente.id == item.id);
    if (indice < 0) return;
    final anterior = _itens[indice];
    _itens[indice] = anterior.copia(obtido: obtido);
    notifyListeners();
    try {
      _itens[indice] = await _itensService.alterarObtido(anterior, obtido);
      await _recarregarResumos();
      _registrarSucesso('alterarObtido', 'item=${item.id}');
    } catch (erro, stackTrace) {
      _itens[indice] = anterior;
      notifyListeners();
      _registrarErro('alterarObtido', erro, stackTrace);
      rethrow;
    }
  }

  Future<Item> criarItem(Item item) async {
    _registrarInicio('criarItem', 'titulo=${item.titulo}');
    try {
      final idLista = _idListaSelecionada;
      if (idLista == null) throw StateError('Nenhuma lista está selecionada.');
      item.idLista = idLista;
      if (item.idCategoria <= 0) {
        final padrao =
            _categorias.where((categoria) => categoria.categoriaPadrao);
        if (padrao.isNotEmpty) item.idCategoria = padrao.first.id!;
      }
      final criado = _criarItemService == null
          ? await _itensService.criar(item)
          : await _criarItemService.executar(
              item: item,
              recorrentesExistentes: _itensRecorrentes,
            );
      if (_itemRecorrenteService != null) {
        _itensRecorrentes
          ..clear()
          ..addAll(await _itemRecorrenteService.recuperarTodos());
        _aoSincronizarItensRecorrentes?.call(
          _itensRecorrentes.map((item) => item.copia()).toList(),
        );
      }
      await _recarregarItensSelecionados();
      await _recarregarResumos();
      notifyListeners();
      _registrarSucesso('criarItem', 'item=${criado.id}');
      return criado;
    } catch (erro, stackTrace) {
      _registrarErro('criarItem', erro, stackTrace);
      rethrow;
    }
  }

  Future<Item> editarItem(Item item) async {
    _registrarInicio('editarItem', 'item=${item.id}');
    try {
      final editado = await _itensService.editar(item);
      await _recarregarItensSelecionados();
      notifyListeners();
      _registrarSucesso('editarItem', 'item=${editado.id}');
      return editado;
    } catch (erro, stackTrace) {
      _registrarErro('editarItem', erro, stackTrace);
      rethrow;
    }
  }

  Future<void> excluirItem(Item item) async {
    _registrarInicio('excluirItem', 'item=${item.id}');
    try {
      await _itensService.excluir(item);
      await _recarregarItensSelecionados();
      await _recarregarResumos();
      notifyListeners();
      _registrarSucesso('excluirItem', 'item=${item.id}');
    } catch (erro, stackTrace) {
      _registrarErro('excluirItem', erro, stackTrace);
      rethrow;
    }
  }

  Future<Item> somarQuantidade(Item item, int quantidade) async {
    if (quantidade <= 0) throw ArgumentError('A quantidade deve ser positiva.');
    final editado = item.copia(
      quantidade: (item.quantidade ?? 0) + quantidade,
    );
    return editarItem(editado);
  }

  void alterarFiltroItens(FiltroItens filtro) {
    filtroItens = filtro;
    notifyListeners();
  }

  void alterarPesquisaItens(String valor) {
    pesquisaItens = valor;
    notifyListeners();
  }

  void alterarOrdenacaoItens(OrdenarPor ordenarPor, Ordem ordem) {
    ordenarItensPor = ordenarPor;
    ordemItens = ordem;
    notifyListeners();
  }

  Future<void> alterarVisualizacaoItens(TipoVisualizacaoItens tipo) async {
    if (tipo == tipoVisualizacaoItens) return;
    await _preferencias.alterarTipoVisualizacao(tipo);
    notifyListeners();
  }

  Future<Historico> salvarNoHistorico() async {
    final service = _salvarHistoricoService;
    final lista = listaSelecionada;
    if (service == null || lista == null) {
      throw StateError('O histórico não está disponível.');
    }
    return service.executar(
      lista: lista,
      itens: _itens,
      titulosCategorias: {
        for (final categoria in _categorias) categoria.id!: categoria.titulo,
      },
    );
  }

  Future<void> _recarregarResumos() async {
    final resumos = await _listasService.recuperarComResumo();
    _listas
      ..clear()
      ..addAll(resumos);
  }

  Future<void> _carregarDadosAuxiliares() async {
    final categoriasService = _categoriasService;
    final recorrenteService = _itemRecorrenteService;
    if (categoriasService != null) {
      _categorias
        ..clear()
        ..addAll(await categoriasService.recuperarTodos());
    }
    if (recorrenteService != null) {
      _itensRecorrentes
        ..clear()
        ..addAll(await recorrenteService.recuperarTodos());
    }
  }

  bool _categoriasIguais(
    List<Categoria> atuais,
    List<Categoria> atualizadas,
  ) {
    if (atuais.length != atualizadas.length) return false;
    for (var indice = 0; indice < atuais.length; indice++) {
      final atual = atuais[indice];
      final atualizada = atualizadas[indice];
      if (atual.id != atualizada.id ||
          atual.titulo != atualizada.titulo ||
          atual.cor != atualizada.cor ||
          atual.ordem != atualizada.ordem ||
          atual.categoriaPadrao != atualizada.categoriaPadrao ||
          atual.excluido != atualizada.excluido) {
        return false;
      }
    }
    return true;
  }

  bool _itensRecorrentesIguais(
    List<ItemRecorrente> atuais,
    List<ItemRecorrente> atualizados,
  ) {
    if (atuais.length != atualizados.length) return false;
    for (var indice = 0; indice < atuais.length; indice++) {
      final atual = atuais[indice];
      final atualizado = atualizados[indice];
      if (atual.id != atualizado.id ||
          atual.idCategoria != atualizado.idCategoria ||
          atual.titulo != atualizado.titulo ||
          atual.tipoMedida != atualizado.tipoMedida ||
          atual.excluido != atualizado.excluido) {
        return false;
      }
    }
    return true;
  }

  int _compararItens(Item primeiro, Item segundo) {
    int comparacao;
    switch (ordenarItensPor) {
      case OrdenarPor.nome:
        comparacao = TextoUtils.normalizarParaOrdenacao(primeiro.titulo)
            .compareTo(TextoUtils.normalizarParaOrdenacao(segundo.titulo));
        break;
      case OrdenarPor.preco:
        comparacao = (primeiro.valorTotal ?? -1).compareTo(
          segundo.valorTotal ?? -1,
        );
        break;
      case OrdenarPor.prioridade:
        comparacao =
            primeiro.prioridade.index.compareTo(segundo.prioridade.index);
        break;
      case OrdenarPor.data:
        comparacao = (primeiro.dataCriacao ?? DateTime(1970)).compareTo(
          segundo.dataCriacao ?? DateTime(1970),
        );
        break;
    }
    return ordemItens == Ordem.ascendente ? comparacao : -comparacao;
  }

  Future<void> _recarregarItensSelecionados() async {
    final idLista = _idListaSelecionada;
    if (idLista == null) return;
    final carregados = await _itensService.buscarPorLista(idLista);
    _itens
      ..clear()
      ..addAll(carregados);
    estadoItens = carregados.isEmpty
        ? EstadoDeTela.carregadaSemDados
        : EstadoDeTela.carregadaComDados;
  }

  Future<void> _selecionarResolvida(
    int? idLista, {
    required bool salvar,
  }) async {
    _idListaSelecionada = idLista;
    _itens.clear();
    final versao = ++_versaoCarregamentoItens;
    if (salvar) await _preferencias.alterarUltimaLista(idLista);
    if (idLista == null) {
      estadoItens = EstadoDeTela.carregadaSemDados;
      notifyListeners();
      return;
    }
    estadoItens = EstadoDeTela.carregando;
    notifyListeners();
    try {
      final carregados = await _itensService.buscarPorLista(idLista);
      if (versao != _versaoCarregamentoItens) return;
      _itens.addAll(carregados);
      estadoItens = carregados.isEmpty
          ? EstadoDeTela.carregadaSemDados
          : EstadoDeTela.carregadaComDados;
      _registrarSucesso(
        'carregarItens',
        'lista=$idLista, itens=${carregados.length}',
      );
    } catch (erro, stackTrace) {
      if (versao != _versaoCarregamentoItens) return;
      estadoItens = EstadoDeTela.erro;
      _registrarErro('carregarItens', erro, stackTrace);
    }
    notifyListeners();
  }

  void _registrarInicio(String operacao, String detalhes) {
    log(
      '$operacao(): iniciando; $detalhes',
      name: LogId.itemController,
    );
  }

  void _registrarSucesso(String operacao, String detalhes) {
    log(
      '$operacao(): concluído com sucesso; $detalhes',
      name: LogId.itemController,
    );
  }

  void _registrarErro(
    String operacao,
    Object erro,
    StackTrace stackTrace,
  ) {
    log(
      '$operacao(): $erro',
      name: LogId.itemController,
      error: erro,
      stackTrace: stackTrace,
    );
  }
}

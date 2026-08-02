// ignore_for_file: prefer_initializing_formals

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
import '../../compartilhamento/model/compartilhamento_model.dart';
import '../../compartilhamento/service/preparar_conteudo_compartilhamento_service.dart';
import '../../historico/model/historico_model.dart';
import '../../historico/service/salvar_historico_service.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/service/item_recorrente_service.dart';
import '../../listas/model/lista_model.dart';
import '../../preferencias_usuario/controller/preferencias_provider.dart';
import '../model/categoria_com_itens_model.dart';
import '../model/filtro_itens.dart';
import '../model/item_model.dart';
import '../model/resumo_financeiro_itens.dart';
import '../model/sugestao_item_recorrente.dart';
import '../service/criar_item_service.dart';
import '../service/itens_service.dart';

class ItensController extends ChangeNotifier {
  final ItensServiceContract _itensService;
  final PreferenciasProvider _preferencias;
  final CategoriasServiceContract? _categoriasService;
  final ItemRecorrenteService? _itemRecorrenteService;
  final CriarItemService? _criarItemService;
  final SalvarHistoricoService? _salvarHistoricoService;
  final PrepararConteudoCompartilhamentoService?
      _prepararConteudoCompartilhamentoService;
  final ValueChanged<List<ItemRecorrente>>? _aoSincronizarItensRecorrentes;
  final List<Item> _itens = [];
  final List<Categoria> _categorias = [];
  final List<ItemRecorrente> _itensRecorrentes = [];

  ItensController(
    this._itensService,
    this._preferencias, {
    CategoriasServiceContract? categoriasService,
    ItemRecorrenteService? itemRecorrenteService,
    CriarItemService? criarItemService,
    SalvarHistoricoService? salvarHistoricoService,
    PrepararConteudoCompartilhamentoService?
        prepararConteudoCompartilhamentoService,
    ValueChanged<List<ItemRecorrente>>? aoSincronizarItensRecorrentes,
  })  : _categoriasService = categoriasService,
        _itemRecorrenteService = itemRecorrenteService,
        _criarItemService = criarItemService,
        _salvarHistoricoService = salvarHistoricoService,
        _prepararConteudoCompartilhamentoService =
            prepararConteudoCompartilhamentoService,
        _aoSincronizarItensRecorrentes = aoSincronizarItensRecorrentes;

  Future<void> Function()? aoAlterarItensPersistidos;
  EstadoDeTela estado = EstadoDeTela.carregando;
  FiltroItens filtro = const FiltroItens();
  OrdenarPor ordenarPor = OrdenarPor.nome;
  Ordem ordem = Ordem.ascendente;
  String pesquisa = '';
  Lista? _listaSelecionada;
  int _versaoCarregamento = 0;

  UnmodifiableListView<Item> get itens => UnmodifiableListView(_itens);
  UnmodifiableListView<Categoria> get categorias =>
      UnmodifiableListView(_categorias);
  UnmodifiableListView<ItemRecorrente> get itensRecorrentes =>
      UnmodifiableListView(_itensRecorrentes);
  Lista? get listaSelecionada => _listaSelecionada;
  int? get idListaSelecionada => _listaSelecionada?.id;

  TipoVisualizacaoItens get tipoVisualizacao =>
      _preferencias.preferencias.tipoVisualizacao;

  ResumoFinanceiroItens get resumoFinanceiro =>
      ResumoFinanceiroItens.calcular(_itens);

  bool get possuiItens => _itens.isNotEmpty;
  bool get possuiItensMarcados => _itens.any((item) => item.obtido);

  ConteudoCompartilhamento prepararConteudoCompartilhamento() {
    final lista = _listaSelecionada;
    final service = _prepararConteudoCompartilhamentoService;
    if (lista == null || service == null) {
      throw StateError('A lista ainda não está pronta para compartilhar.');
    }
    return service.prepararComDados(
      lista,
      itens: _itens,
      categorias: _categorias,
    );
  }

  List<Item> get itensVisiveis {
    final termo = TextoUtils.normalizarParaOrdenacao(pesquisa);
    final resultado = _itens.where((item) {
      if (filtro.situacao == SituacaoItem.pendentes && item.obtido) {
        return false;
      }
      if (filtro.situacao == SituacaoItem.marcados && !item.obtido) {
        return false;
      }
      if (filtro.idCategoria != null &&
          item.idCategoria != filtro.idCategoria) {
        return false;
      }
      if (filtro.prioridade != null && item.prioridade != filtro.prioridade) {
        return false;
      }
      if (filtro.possuiPreco != null &&
          (item.preco != null) != filtro.possuiPreco) {
        return false;
      }
      return termo.isEmpty ||
          TextoUtils.normalizarParaOrdenacao(item.titulo).contains(termo);
    }).toList()
      ..sort(_compararItens);
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
    for (final entrada in porCategoria.entries) {
      grupos.add(CategoriaComItens(
        categoria: Categoria(
          id: entrada.key,
          titulo: 'Sem categoria',
          cor: _listaSelecionada?.cor ?? const Color(0xFF795548),
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

  Item? localizarDuplicado(String titulo) =>
      ItensService.localizarDuplicado(_itens, titulo);

  Future<void> carregarDadosAuxiliares() async {
    if (_categoriasService != null) {
      _categorias
        ..clear()
        ..addAll(await _categoriasService.recuperarTodos());
    }
    if (_itemRecorrenteService != null) {
      _itensRecorrentes
        ..clear()
        ..addAll(await _itemRecorrenteService.recuperarTodos());
    }
  }

  void sincronizarCategorias(Iterable<Categoria> categorias) {
    final atualizadas =
        categorias.map((categoria) => categoria.copia()).toList()
          ..sort((a, b) {
            final porOrdem = a.ordem.compareTo(b.ordem);
            return porOrdem != 0 ? porOrdem : (a.id ?? 0).compareTo(b.id ?? 0);
          });
    if (_categoriasIguais(_categorias, atualizadas)) return;
    _categorias
      ..clear()
      ..addAll(atualizadas);
    notifyListeners();
  }

  void sincronizarItensRecorrentes(Iterable<ItemRecorrente> itens) {
    final atualizados = itens.map((item) => item.copia()).toList();
    if (_itensRecorrentesIguais(_itensRecorrentes, atualizados)) return;
    _itensRecorrentes
      ..clear()
      ..addAll(atualizados);
    notifyListeners();
  }

  Future<void> selecionarLista(Lista? lista, {bool forcar = false}) async {
    final mesmoId = lista?.id == _listaSelecionada?.id;
    _listaSelecionada = lista?.copia();
    if (mesmoId && !forcar && estado != EstadoDeTela.erro) {
      notifyListeners();
      return;
    }
    _itens.clear();
    final versao = ++_versaoCarregamento;
    if (lista?.id == null) {
      estado = EstadoDeTela.carregadaSemDados;
      notifyListeners();
      return;
    }
    estado = EstadoDeTela.carregando;
    notifyListeners();
    try {
      final carregados = await _itensService.buscarPorLista(lista!.id!);
      if (versao != _versaoCarregamento) return;
      _itens.addAll(carregados);
      estado = carregados.isEmpty
          ? EstadoDeTela.carregadaSemDados
          : EstadoDeTela.carregadaComDados;
    } catch (erro, stackTrace) {
      if (versao != _versaoCarregamento) return;
      estado = EstadoDeTela.erro;
      _registrarErro('carregarItens', erro, stackTrace);
    }
    notifyListeners();
  }

  Future<void> recarregar() => selecionarLista(_listaSelecionada, forcar: true);

  Future<void> alterarObtido(Item item, bool obtido) async {
    final idLista = idListaSelecionada;
    final indice = _itens.indexWhere((existente) => existente.id == item.id);
    if (indice < 0) return;
    final anterior = _itens[indice];
    _itens[indice] = anterior.copia(obtido: obtido);
    notifyListeners();
    try {
      final persistido = await _itensService.alterarObtido(anterior, obtido);
      if (idListaSelecionada != idLista) return;
      final indiceAtual =
          _itens.indexWhere((existente) => existente.id == item.id);
      if (indiceAtual < 0) return;
      _itens[indiceAtual] = persistido;
      await _notificarAlteracaoPersistida();
      notifyListeners();
    } catch (erro, stackTrace) {
      if (idListaSelecionada == idLista) {
        final indiceAtual =
            _itens.indexWhere((existente) => existente.id == item.id);
        if (indiceAtual >= 0) {
          _itens[indiceAtual] = anterior;
          notifyListeners();
        }
      }
      _registrarErro('alterarObtido', erro, stackTrace);
      rethrow;
    }
  }

  Future<Item> criar(Item item) async {
    final idLista = idListaSelecionada;
    if (idLista == null) throw StateError('Nenhuma lista está selecionada.');
    final novo = item.copia(idLista: idLista);
    final criado = _criarItemService == null
        ? await _itensService.criar(novo)
        : await _criarItemService.executar(
            item: novo,
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
    await _notificarAlteracaoPersistida();
    notifyListeners();
    return criado;
  }

  Future<Item> editar(Item item) async {
    final editado = await _itensService.editar(item);
    await _recarregarItensSelecionados();
    await _notificarAlteracaoPersistida();
    notifyListeners();
    return editado;
  }

  Future<void> excluir(Item item) async {
    await _itensService.excluir(item);
    await _recarregarItensSelecionados();
    await _notificarAlteracaoPersistida();
    notifyListeners();
  }

  Future<Item> somarQuantidade(Item item, int quantidade) async {
    final editado = await _itensService.somarQuantidade(item, quantidade);
    await _recarregarItensSelecionados();
    await _notificarAlteracaoPersistida();
    notifyListeners();
    return editado;
  }

  void alterarFiltro(FiltroItens valor) {
    filtro = valor;
    notifyListeners();
  }

  void alterarPesquisa(String valor) {
    pesquisa = valor;
    notifyListeners();
  }

  void alterarOrdenacao(OrdenarPor valor, Ordem novaOrdem) {
    ordenarPor = valor;
    ordem = novaOrdem;
    notifyListeners();
  }

  Future<void> alterarVisualizacao(TipoVisualizacaoItens tipo) async {
    if (tipo == tipoVisualizacao) return;
    await _preferencias.alterarTipoVisualizacao(tipo);
    notifyListeners();
  }

  Future<Historico> salvarNoHistorico() async {
    final service = _salvarHistoricoService;
    final lista = _listaSelecionada;
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

  Future<void> _recarregarItensSelecionados() async {
    final idLista = idListaSelecionada;
    if (idLista == null) return;
    final versao = ++_versaoCarregamento;
    final carregados = await _itensService.buscarPorLista(idLista);
    if (versao != _versaoCarregamento || idLista != idListaSelecionada) return;
    _itens
      ..clear()
      ..addAll(carregados);
    estado = carregados.isEmpty
        ? EstadoDeTela.carregadaSemDados
        : EstadoDeTela.carregadaComDados;
  }

  Future<void> _notificarAlteracaoPersistida() async {
    await aoAlterarItensPersistidos?.call();
  }

  int _compararItens(Item primeiro, Item segundo) {
    int comparacao;
    switch (ordenarPor) {
      case OrdenarPor.nome:
        comparacao = TextoUtils.normalizarParaOrdenacao(primeiro.titulo)
            .compareTo(TextoUtils.normalizarParaOrdenacao(segundo.titulo));
      case OrdenarPor.preco:
        comparacao =
            (primeiro.valorTotal ?? -1).compareTo(segundo.valorTotal ?? -1);
      case OrdenarPor.prioridade:
        comparacao =
            primeiro.prioridade.index.compareTo(segundo.prioridade.index);
      case OrdenarPor.data:
        comparacao = (primeiro.dataCriacao ?? DateTime(1970))
            .compareTo(segundo.dataCriacao ?? DateTime(1970));
    }
    return ordem == Ordem.ascendente ? comparacao : -comparacao;
  }

  bool _categoriasIguais(List<Categoria> atuais, List<Categoria> novas) {
    if (atuais.length != novas.length) return false;
    for (var i = 0; i < atuais.length; i++) {
      final a = atuais[i];
      final b = novas[i];
      if (a.id != b.id ||
          a.titulo != b.titulo ||
          a.cor != b.cor ||
          a.ordem != b.ordem ||
          a.categoriaPadrao != b.categoriaPadrao ||
          a.excluido != b.excluido) {
        return false;
      }
    }
    return true;
  }

  bool _itensRecorrentesIguais(
    List<ItemRecorrente> atuais,
    List<ItemRecorrente> novos,
  ) {
    if (atuais.length != novos.length) return false;
    for (var i = 0; i < atuais.length; i++) {
      final a = atuais[i];
      final b = novos[i];
      if (a.id != b.id ||
          a.idCategoria != b.idCategoria ||
          a.titulo != b.titulo ||
          a.tipoMedida != b.tipoMedida ||
          a.excluido != b.excluido) {
        return false;
      }
    }
    return true;
  }

  void _registrarErro(String operacao, Object erro, StackTrace stackTrace) {
    log(
      '$operacao(): $erro',
      name: LogId.itemController,
      error: erro,
      stackTrace: stackTrace,
    );
  }
}

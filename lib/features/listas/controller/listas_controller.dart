import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/logs/logs.dart';
import '../../../core/utils/texto_utils.dart';
import '../../categoria/service/categorias_service.dart';
import '../../compartilhamento/model/compartilhamento_model.dart';
import '../../compartilhamento/service/preparar_conteudo_compartilhamento_service.dart';
import '../../historico/service/salvar_historico_service.dart';
import '../../itens/controller/itens_controller.dart';
import '../../itens/service/criar_item_service.dart';
import '../../itens/service/itens_service.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/service/item_recorrente_service.dart';
import '../../preferencias_usuario/controller/preferencias_provider.dart';
import '../model/lista_com_resumo_de_itens_model.dart';
import '../model/lista_model.dart';
import '../service/listas_service.dart';

class ListasController extends ChangeNotifier {
  final ListasServiceContract _listasService;
  final PreferenciasProvider _preferencias;
  final PrepararConteudoCompartilhamentoService?
      _prepararConteudoCompartilhamentoService;
  final List<ListaComResumoDeItens> _listas = [];
  late final ItensController itensController;

  ListasController(
    this._listasService,
    ItensServiceContract itensService,
    this._preferencias, {
    CategoriasServiceContract? categoriasService,
    ItemRecorrenteService? itemRecorrenteService,
    CriarItemService? criarItemService,
    SalvarHistoricoServiceContract? salvarHistoricoService,
    PrepararConteudoCompartilhamentoService?
        prepararConteudoCompartilhamentoService,
    ValueChanged<List<ItemRecorrente>>? aoSincronizarItensRecorrentes,
  }) : _prepararConteudoCompartilhamentoService =
            prepararConteudoCompartilhamentoService {
    itensController = ItensController(
      itensService,
      _preferencias,
      categoriasService: categoriasService,
      itemRecorrenteService: itemRecorrenteService,
      criarItemService: criarItemService,
      salvarHistoricoService: salvarHistoricoService,
      prepararConteudoCompartilhamentoService:
          prepararConteudoCompartilhamentoService,
      aoSincronizarItensRecorrentes: aoSincronizarItensRecorrentes,
    )..aoAlterarItensPersistidos = _atualizarResumosAposItens;
  }

  EstadoDeTela estado = EstadoDeTela.carregando;
  String? mensagemErro;
  int? _idListaSelecionada;
  int _versaoSelecao = 0;
  bool alterandoOrdem = false;

  UnmodifiableListView<ListaComResumoDeItens> get listas =>
      UnmodifiableListView(_listas);
  int? get idListaSelecionada => _idListaSelecionada;

  Lista? get listaSelecionada {
    for (final resumo in _listas) {
      if (resumo.lista.id == _idListaSelecionada) return resumo.lista;
    }
    return null;
  }

  Future<ConteudoCompartilhamento> prepararConteudoCompartilhamento(
    Lista lista,
  ) {
    final service = _prepararConteudoCompartilhamentoService;
    if (service == null) {
      throw StateError('O compartilhamento ainda não está disponível.');
    }
    return service.prepararLista(lista);
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
    mensagemErro = null;
    estado = EstadoDeTela.carregando;
    notifyListeners();
    try {
      await _recarregarResumos();
      await itensController.carregarDadosAuxiliares();
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
    } catch (erro, stackTrace) {
      mensagemErro = 'Não foi possível carregar as listas.';
      estado = EstadoDeTela.erro;
      _registrarErro('carregar', erro, stackTrace);
      notifyListeners();
    }
  }

  Future<void> selecionar(int idLista) async {
    final mesmaLista = _idListaSelecionada == idLista;
    if (mesmaLista && itensController.estado != EstadoDeTela.erro) return;
    if (!_listas.any((resumo) => resumo.lista.id == idLista)) {
      throw StateError('A lista selecionada não está disponível.');
    }
    await _selecionarResolvida(idLista,
        salvar: !mesmaLista, forcar: mesmaLista);
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
    if (editada.id == _idListaSelecionada) {
      await itensController.selecionarLista(editada);
    }
    notifyListeners();
    return editada;
  }

  Future<void> alternarFixacao(Lista lista) async {
    await editar(lista.copia()..fixada = !lista.fixada);
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
      await _recarregarResumos();
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
      return TextoUtils.normalizarParaOrdenacao(a.lista.titulo)
          .compareTo(TextoUtils.normalizarParaOrdenacao(b.lista.titulo));
    });
    notifyListeners();
    try {
      await _listasService.atualizarOrdens(
        _listas.map((resumo) => resumo.lista).toList(),
      );
      await _recarregarResumos();
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

  Future<void> recarregarAposReutilizacao() async {
    await itensController.recarregar();
    await _recarregarResumos();
    notifyListeners();
  }

  Future<void> _selecionarResolvida(
    int? idLista, {
    required bool salvar,
    bool forcar = false,
  }) async {
    final versao = ++_versaoSelecao;
    if (salvar) await _preferencias.alterarUltimaLista(idLista);
    if (versao != _versaoSelecao) return;
    _idListaSelecionada = idLista;
    notifyListeners();
    await itensController.selecionarLista(listaSelecionada, forcar: forcar);
  }

  Future<void> _recarregarResumos() async {
    final resumos = await _listasService.recuperarComResumo();
    _listas
      ..clear()
      ..addAll(resumos);
  }

  Future<void> _atualizarResumosAposItens() async {
    await _recarregarResumos();
    notifyListeners();
  }

  void _registrarErro(String operacao, Object erro, StackTrace stackTrace) {
    log(
      '$operacao(): $erro',
      name: LogId.listaController,
      error: erro,
      stackTrace: stackTrace,
    );
  }
}

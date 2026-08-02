import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/utils/texto_utils.dart';
import '../../compartilhamento/model/compartilhamento_model.dart';
import '../../listas/model/lista_model.dart';
import '../model/filtro_historico.dart';
import '../model/historico_com_itens_model.dart';
import '../model/historico_model.dart';
import '../model/resultado_reutilizacao_historico.dart';
import '../service/reutilizar_historico_service.dart';
import '../service/historico_service.dart';

class HistoricoController extends ChangeNotifier {
  HistoricoController(
    this._service, {
    this.reutilizarService,
  });

  final HistoricoServiceContract _service;
  final ReutilizarHistoricoServiceContract? reutilizarService;
  final List<HistoricoComItens> _compras = [];

  EstadoDeTela estado = EstadoDeTela.carregando;
  String? mensagemErro;
  String pesquisa = '';
  PeriodoHistorico periodo = PeriodoHistorico.todos;
  OrdenacaoHistorico ordenacao = OrdenacaoHistorico.maisRecentes;
  final Set<int> _operacoesEmAndamento = {};

  UnmodifiableListView<HistoricoComItens> get compras =>
      UnmodifiableListView(_compras);

  List<HistoricoComItens> get comprasVisiveis {
    final termo = TextoUtils.normalizarParaOrdenacao(pesquisa);
    final limite = periodo.dias == null
        ? null
        : DateTime.now().subtract(Duration(days: periodo.dias!));
    final resultado = _compras.where((compra) {
      if (limite != null && compra.historico.dataCompra.isBefore(limite)) {
        return false;
      }
      if (termo.isEmpty) return true;
      return TextoUtils.normalizarParaOrdenacao(compra.historico.titulo)
              .contains(termo) ||
          compra.itens.any(
            (item) =>
                TextoUtils.normalizarParaOrdenacao(item.titulo).contains(termo),
          );
    }).toList(growable: false);
    switch (ordenacao) {
      case OrdenacaoHistorico.maisRecentes:
        resultado.sort(
          (a, b) => b.historico.dataCompra.compareTo(a.historico.dataCompra),
        );
      case OrdenacaoHistorico.maisAntigos:
        resultado.sort(
          (a, b) => a.historico.dataCompra.compareTo(b.historico.dataCompra),
        );
      case OrdenacaoHistorico.maiorValor:
        resultado.sort((a, b) => b.valorTotal.compareTo(a.valorTotal));
    }
    return List.unmodifiable(resultado);
  }

  bool operacaoEmAndamento(HistoricoComItens compra) =>
      _operacoesEmAndamento.contains(compra.historico.id);

  Future<void> carregar() async {
    estado = EstadoDeTela.carregando;
    mensagemErro = null;
    notifyListeners();
    try {
      _compras
        ..clear()
        ..addAll(await _service.recuperarTodos());
      estado = _compras.isEmpty
          ? EstadoDeTela.carregadaSemDados
          : EstadoDeTela.carregadaComDados;
    } catch (_) {
      mensagemErro = 'Não foi possível carregar o histórico.';
      estado = EstadoDeTela.erro;
    }
    notifyListeners();
  }

  ConteudoCompartilhamento prepararCompartilhamento(
    HistoricoComItens compra,
  ) =>
      _service.prepararCompartilhamento(compra);

  void alterarPesquisa(String valor) {
    pesquisa = valor;
    notifyListeners();
  }

  void alterarPeriodo(PeriodoHistorico valor) {
    if (periodo == valor) return;
    periodo = valor;
    notifyListeners();
  }

  void alterarOrdenacao(OrdenacaoHistorico valor) {
    if (ordenacao == valor) return;
    ordenacao = valor;
    notifyListeners();
  }

  Future<void> editar(HistoricoComItens compra, Historico historico) async {
    await _executarNaCompra(compra, () async {
      final editado = await _service.editar(historico);
      final indice = _compras.indexWhere(
        (item) => item.historico.id == compra.historico.id,
      );
      if (indice >= 0) {
        _compras[indice] = HistoricoComItens(
          historico: editado,
          itens: compra.itens,
        );
      }
    });
  }

  Future<void> excluir(HistoricoComItens compra) async {
    await _executarNaCompra(compra, () async {
      await _service.excluir(compra.historico);
      _compras.removeWhere(
        (item) => item.historico.id == compra.historico.id,
      );
      estado = _compras.isEmpty
          ? EstadoDeTela.carregadaSemDados
          : EstadoDeTela.carregadaComDados;
    });
  }

  Future<ResultadoReutilizacaoHistorico> reutilizar(
    HistoricoComItens compra,
    Lista listaDestino, {
    bool adicionarDuplicados = false,
  }) async {
    final service = reutilizarService;
    if (service == null) {
      throw StateError('A reutilização do histórico não está disponível.');
    }
    late ResultadoReutilizacaoHistorico resultado;
    await _executarNaCompra(compra, () async {
      resultado = await service.executar(
        compra: compra,
        listaDestino: listaDestino,
        adicionarDuplicados: adicionarDuplicados,
      );
    });
    return resultado;
  }

  Future<void> _executarNaCompra(
    HistoricoComItens compra,
    Future<void> Function() operacao,
  ) async {
    final id = compra.historico.id;
    if (id == null) throw StateError('A compra precisa estar persistida.');
    if (_operacoesEmAndamento.contains(id)) {
      throw StateError('Já existe uma operação em andamento nesta compra.');
    }
    _operacoesEmAndamento.add(id);
    notifyListeners();
    try {
      await operacao();
    } finally {
      _operacoesEmAndamento.remove(id);
      notifyListeners();
    }
  }
}

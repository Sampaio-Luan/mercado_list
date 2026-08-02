import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../compartilhamento/model/compartilhamento_model.dart';
import '../model/historico_com_itens_model.dart';
import '../service/historico_service.dart';

class HistoricoController extends ChangeNotifier {
  HistoricoController(this._service);

  final HistoricoServiceContract _service;
  final List<HistoricoComItens> _compras = [];

  EstadoDeTela estado = EstadoDeTela.carregando;
  String? mensagemErro;

  UnmodifiableListView<HistoricoComItens> get compras =>
      UnmodifiableListView(_compras);

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
}

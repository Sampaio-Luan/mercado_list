import 'dart:developer';

import 'package:flutter/material.dart';

import '../../core/constants/enums/tema_app.dart';
import '../../core/constants/enums/tipo_visualizacao_itens.dart';
import '../../core/services/preferencias_service.dart';
import 'preferencias_usuario_model.dart';


class PreferenciasProvider extends ChangeNotifier {
  final PreferenciasService _service;

  PreferenciasUsuario _preferencias = PreferenciasUsuario.padrao();

  PreferenciasProvider(this._service);

  PreferenciasUsuario get preferencias => _preferencias;
  static const String msg = '🎲🥇PreferenciasProvider';

  Future<void> carregar() async {
    _preferencias = _service.carregar();

    notifyListeners();
  }

  Future<void> alterarTema(TemaApp tema) async {
    _preferencias = _preferencias.copyWith(tema: tema);

    await _service.salvar(_preferencias);
    log(
      name: msg,
      'alterarTema(): Tema alterado para: ${tema.name}',
    );
    notifyListeners();
  }

  Future<void> alterarTipoVisualizacao(TipoVisualizacaoItens tipo) async {
    _preferencias = _preferencias.copyWith(tipoVisualizacao: tipo);

    await _service.salvar(_preferencias);

    notifyListeners();
  }

  Future<void> alterarUltimaLista(int idLista) async {
    _preferencias = _preferencias.copyWith(ultimaListaAberta: idLista);

    await _service.salvar(_preferencias);

    notifyListeners();
  }

  Future<void> alterarMostrarComprados(bool valor) async {
    _preferencias = _preferencias.copyWith(mostrarItensComprados: valor);

    await _service.salvar(_preferencias);

    notifyListeners();
  }
}

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../model/compartilhamento_model.dart';
import '../service/compartilhamento_service.dart';

class CompartilhamentoController extends ChangeNotifier {
  CompartilhamentoController(this.conteudo, this._service)
      : camposSelecionados = {CampoCompartilhamento.titulo};

  final ConteudoCompartilhamento conteudo;
  final CompartilhamentoService _service;

  EscopoCompartilhamento escopo = EscopoCompartilhamento.todos;
  FormatoCompartilhamento formato = FormatoCompartilhamento.texto;
  Set<CampoCompartilhamento> camposSelecionados;
  bool compartilhando = false;
  String? mensagemErro;

  void selecionarEscopo(EscopoCompartilhamento valor) {
    if (conteudo.quantidadeNoEscopo(valor) == 0 || escopo == valor) return;
    escopo = valor;
    mensagemErro = null;
    notifyListeners();
  }

  void selecionarFormato(FormatoCompartilhamento valor) {
    if (formato == valor) return;
    formato = valor;
    mensagemErro = null;
    notifyListeners();
  }

  void alternarCampo(CampoCompartilhamento campo) {
    if (campo == CampoCompartilhamento.titulo) return;
    final atualizados = Set<CampoCompartilhamento>.of(camposSelecionados);
    atualizados.contains(campo)
        ? atualizados.remove(campo)
        : atualizados.add(campo);
    camposSelecionados = atualizados;
    mensagemErro = null;
    notifyListeners();
  }

  Future<ShareResultStatus?> compartilhar({Rect? origem}) async {
    if (compartilhando) return null;
    compartilhando = true;
    mensagemErro = null;
    notifyListeners();
    try {
      return await _service.compartilhar(
        ConfiguracaoCompartilhamento(
          conteudo: conteudo,
          escopo: escopo,
          campos: camposSelecionados,
          formato: formato,
        ),
        origem: origem,
      );
    } catch (erro) {
      mensagemErro = _mensagemAmigavel(erro);
      return null;
    } finally {
      compartilhando = false;
      notifyListeners();
    }
  }

  String _mensagemAmigavel(Object erro) {
    if (erro is StateError || erro is ArgumentError) {
      return erro.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
    }
    if (erro is UnimplementedError || erro is UnsupportedError) {
      return 'O compartilhamento desse formato não está disponível neste dispositivo.';
    }
    return 'Não foi possível preparar o compartilhamento. Tente novamente.';
  }
}

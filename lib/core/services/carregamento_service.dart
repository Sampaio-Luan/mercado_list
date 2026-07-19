import 'package:flutter/material.dart';

import '../model/progresso_operacao.dart';
import '../../shared/widgets/card_progresso_operacao.dart';

class CarregamentoService {
  CarregamentoService._();

  static bool _aberto = false;

  static Future<T> executar<T>({
    required BuildContext context,
    required String titulo,
    required Future<T> Function(AoProgredir atualizar) operacao,
    String descricaoInicial = 'Preparando a operação...',
    String mensagemSucesso = 'Operação concluída com sucesso.',
    String mensagemErro = 'Não foi possível concluir a operação.',
    Duration duracaoMinima = const Duration(milliseconds: 500),
    Duration duracaoSucesso = const Duration(milliseconds: 900),
  }) async {
    if (_aberto) {
      throw StateError('Já existe uma operação em andamento.');
    }

    _aberto = true;
    final inicio = DateTime.now();
    final navegador = Navigator.of(context, rootNavigator: true);
    final progresso = ValueNotifier<_ProgressoOperacao>(
      _ProgressoOperacao(descricao: descricaoInicial),
    );
    final dialogo = _mostrarDialogo(
      context: context,
      titulo: titulo,
      navegador: navegador,
      progresso: progresso,
    );

    try {
      await WidgetsBinding.instance.endOfFrame;
      final resultado = await operacao((atualizacao) {
        progresso.value = progresso.value.atualizar(
          etapaAtual: atualizacao.etapa,
          totalEtapas: atualizacao.total,
          descricao: atualizacao.descricao,
        );
      });

      await _aguardarDuracaoMinima(inicio, duracaoMinima);
      progresso.value = progresso.value.concluir(mensagemSucesso);
      await Future<void>.delayed(duracaoSucesso);
      _fecharDialogo(navegador);
      await dialogo;
      return resultado;
    } catch (_) {
      await _aguardarDuracaoMinima(inicio, duracaoMinima);
      progresso.value = progresso.value.falhar(mensagemErro);
      await dialogo;
      rethrow;
    } finally {
      _aberto = false;
      progresso.dispose();
    }
  }

  static Future<void> _mostrarDialogo({
    required BuildContext context,
    required String titulo,
    required NavigatorState navegador,
    required ValueNotifier<_ProgressoOperacao> progresso,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ValueListenableBuilder<_ProgressoOperacao>(
        valueListenable: progresso,
        builder: (_, valor, _) => CardProgressoOperacao(
          titulo: titulo,
          descricao: valor.descricao,
          etapaAtual: valor.etapaAtual,
          totalEtapas: valor.totalEtapas,
          estado: valor.estado,
          onFechar: () => _fecharDialogo(navegador),
        ),
      ),
    );
  }

  static Future<void> _aguardarDuracaoMinima(
    DateTime inicio,
    Duration duracaoMinima,
  ) async {
    final tempoDecorrido = DateTime.now().difference(inicio);
    final tempoRestante = duracaoMinima - tempoDecorrido;
    if (!tempoRestante.isNegative) {
      await Future<void>.delayed(tempoRestante);
    }
  }

  static void _fecharDialogo(NavigatorState navegador) {
    if (navegador.mounted && navegador.canPop()) {
      navegador.pop();
    }
  }
}

class _ProgressoOperacao {
  final String descricao;
  final int etapaAtual;
  final int totalEtapas;
  final EstadoProgressoOperacao estado;

  const _ProgressoOperacao({
    required this.descricao,
    this.etapaAtual = 0,
    this.totalEtapas = 0,
    this.estado = EstadoProgressoOperacao.processando,
  });

  _ProgressoOperacao atualizar({
    required int etapaAtual,
    required int totalEtapas,
    required String descricao,
  }) {
    return _ProgressoOperacao(
      descricao: descricao,
      etapaAtual: etapaAtual,
      totalEtapas: totalEtapas,
    );
  }

  _ProgressoOperacao concluir(String mensagem) {
    return _ProgressoOperacao(
      descricao: mensagem,
      etapaAtual: totalEtapas,
      totalEtapas: totalEtapas,
      estado: EstadoProgressoOperacao.sucesso,
    );
  }

  _ProgressoOperacao falhar(String mensagem) {
    return _ProgressoOperacao(
      descricao: mensagem,
      etapaAtual: etapaAtual,
      totalEtapas: totalEtapas,
      estado: EstadoProgressoOperacao.erro,
    );
  }
}

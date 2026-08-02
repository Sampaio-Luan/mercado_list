import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/extensions/dialogo_extension.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../compartilhamento/service/compartilhamento_service.dart';
import '../../compartilhamento/widget/compartilhamento_sheet.dart';
import '../../listas/controller/listas_controller.dart';
import '../controller/historico_controller.dart';
import '../form/historico_formulario.dart';
import '../model/historico_com_itens_model.dart';
import '../widget/barra_historico.dart';
import '../widget/historico_card.dart';
import '../widget/historico_detalhes_sheet.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key, this.corDestaque});

  final Color? corDestaque;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HistoricoController>();
    final cor = corDestaque ?? Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de compras')),
      body: switch (controller.estado) {
        EstadoDeTela.carregando => const Center(
            child: CircularProgressIndicator(),
          ),
        EstadoDeTela.erro => _EstadoHistorico(
            icone: Icons.error_outline,
            mensagem:
                controller.mensagemErro ?? 'O histórico não está disponível.',
            textoAcao: 'Tentar novamente',
            aoAcionar: controller.carregar,
          ),
        EstadoDeTela.carregadaSemDados => const _EstadoHistorico(
            icone: Icons.history_toggle_off,
            mensagem: 'As compras salvas aparecerão aqui.',
          ),
        _ => Column(
            children: [
              BarraHistorico(
                periodo: controller.periodo,
                ordenacao: controller.ordenacao,
                corDestaque: cor,
                aoPesquisar: controller.alterarPesquisa,
                aoAlterarPeriodo: controller.alterarPeriodo,
                aoAlterarOrdenacao: controller.alterarOrdenacao,
              ),
              Expanded(
                child: controller.comprasVisiveis.isEmpty
                    ? const _EstadoHistorico(
                        icone: Icons.search_off_outlined,
                        mensagem: 'Nenhuma compra corresponde aos filtros.',
                      )
                    : RefreshIndicator(
                        color: cor,
                        onRefresh: controller.carregar,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemCount: controller.comprasVisiveis.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, indice) {
                            final compra = controller.comprasVisiveis[indice];
                            return HistoricoCard(
                              compra: compra,
                              aoAbrir: () => _abrirDetalhes(
                                context,
                                controller,
                                compra,
                              ),
                              aoCompartilhar: () => _compartilhar(
                                context,
                                controller,
                                compra,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
      },
    );
  }

  Future<void> _abrirDetalhes(
    BuildContext context,
    HistoricoController controller,
    HistoricoComItens compra,
  ) {
    return HistoricoDetalhesSheet.exibir(
      context,
      compra: compra,
      operacaoEmAndamento: controller.operacaoEmAndamento(compra),
      aoEditar: () => _aposFecharDetalhes(
        context,
        () => HistoricoFormulario.exibir(context, compra),
      ),
      aoCompartilhar: () => _aposFecharDetalhes(
        context,
        () => _compartilhar(context, controller, compra),
      ),
      aoReutilizar: () => _aposFecharDetalhes(
        context,
        () => _reutilizar(context, controller, compra),
      ),
      aoExcluir: () => _aposFecharDetalhes(
        context,
        () => _excluir(context, controller, compra),
      ),
    );
  }

  Future<void> _aposFecharDetalhes(
    BuildContext context,
    Future<void> Function() acao,
  ) async {
    Navigator.of(context).pop();
    await Future<void>.delayed(Duration.zero);
    if (context.mounted) await acao();
  }

  Future<void> _reutilizar(
    BuildContext context,
    HistoricoController controller,
    HistoricoComItens compra,
  ) async {
    final listasController = context.read<ListasController>();
    final lista = listasController.listaSelecionada;
    if (lista == null) {
      context.mostrarAviso('Selecione uma lista antes de reutilizar a compra.');
      return;
    }
    final confirmacao = await context.confirmar(
      titulo: 'Reutilizar compra',
      mensagem: 'Adicionar os itens de "${compra.historico.titulo}" à lista '
          '"${lista.titulo}"? Itens com o mesmo título serão ignorados.',
      textoConfirmar: 'Adicionar itens',
    );
    if (confirmacao != ResultadoDialogo.confirmar || !context.mounted) return;
    try {
      final resultado = await controller.reutilizar(compra, lista);
      await listasController.recarregarAposReutilizacao();
      if (!context.mounted) return;
      context.mostrarSucesso(
        '${resultado.adicionados} itens adicionados'
        '${resultado.ignorados > 0 ? ' e ${resultado.ignorados} ignorados' : ''}.',
      );
    } catch (_) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível reutilizar esta compra.');
      }
    }
  }

  Future<void> _excluir(
    BuildContext context,
    HistoricoController controller,
    HistoricoComItens compra,
  ) async {
    final confirmacao = await context.confirmar(
      titulo: 'Excluir compra',
      mensagem: 'Deseja excluir "${compra.historico.titulo}" do histórico?',
      textoConfirmar: 'Excluir',
    );
    if (confirmacao != ResultadoDialogo.confirmar || !context.mounted) return;
    try {
      await controller.excluir(compra);
      if (context.mounted) {
        context.mostrarSucesso('Compra excluída do histórico.');
      }
    } catch (_) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível excluir a compra.');
      }
    }
  }

  Future<void> _compartilhar(
    BuildContext context,
    HistoricoController controller,
    HistoricoComItens compra,
  ) async {
    try {
      await CompartilhamentoSheet.exibir(
        context,
        conteudo: controller.prepararCompartilhamento(compra),
        corDestaque: compra.historico.cor,
        service: context.read<CompartilhamentoService>(),
      );
    } catch (_) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível compartilhar a compra.');
      }
    }
  }
}

class _EstadoHistorico extends StatelessWidget {
  const _EstadoHistorico({
    required this.icone,
    required this.mensagem,
    this.textoAcao,
    this.aoAcionar,
  });

  final IconData icone;
  final String mensagem;
  final String? textoAcao;
  final Future<void> Function()? aoAcionar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 52),
            const SizedBox(height: 12),
            Text(mensagem, textAlign: TextAlign.center),
            if (textoAcao != null && aoAcionar != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: aoAcionar, child: Text(textoAcao!)),
            ],
          ],
        ),
      ),
    );
  }
}

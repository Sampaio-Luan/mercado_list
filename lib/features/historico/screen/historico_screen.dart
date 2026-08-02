import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/extensions/cor_contraste_extension.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/utils/data_utils.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../compartilhamento/service/compartilhamento_service.dart';
import '../../compartilhamento/widget/compartilhamento_sheet.dart';
import '../controller/historico_controller.dart';
import '../model/historico_com_itens_model.dart';

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
        EstadoDeTela.carregadaComDados => RefreshIndicator(
            color: cor,
            onRefresh: controller.carregar,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.compras.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, indice) => _CartaoHistorico(
                compra: controller.compras[indice],
                corDestaque: cor,
                aoCompartilhar: () => _compartilhar(
                  context,
                  controller,
                  controller.compras[indice],
                  cor,
                ),
              ),
            ),
          ),
      },
    );
  }

  Future<void> _compartilhar(
    BuildContext context,
    HistoricoController controller,
    HistoricoComItens compra,
    Color cor,
  ) async {
    try {
      await CompartilhamentoSheet.exibir(
        context,
        conteudo: controller.prepararCompartilhamento(compra),
        corDestaque: cor,
        service: context.read<CompartilhamentoService>(),
      );
    } catch (erro) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível compartilhar: $erro');
      }
    }
  }
}

class _CartaoHistorico extends StatelessWidget {
  const _CartaoHistorico({
    required this.compra,
    required this.corDestaque,
    required this.aoCompartilhar,
  });

  final HistoricoComItens compra;
  final Color corDestaque;
  final VoidCallback aoCompartilhar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final corAcao = corDestaque.paraPrimeiroPlano(tema);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(compra.historico.titulo,
                      style: tema.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    DataUtils.formatarData(compra.historico.dataCompra),
                    style: tema.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${compra.itens.length} ${compra.itens.length == 1 ? 'item' : 'itens'}  •  '
                    '${MonetarioUtils.formatarIntToMoeda(compra.valorTotal)}',
                    style: tema.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Compartilhar compra',
              onPressed: compra.itens.isEmpty ? null : aoCompartilhar,
              color: corAcao,
              icon: const Icon(Icons.ios_share_outlined),
            ),
          ],
        ),
      ),
    );
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

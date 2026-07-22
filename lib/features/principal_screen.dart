import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../core/extensions/snackbar_extension.dart';
import 'itens/screen/lista_itens_screen.dart';
import 'itens_recorrentes/screen/itens_recorrentes_drawer.dart';
import 'listas/controller/listas_controller.dart';
import 'listas/screen/lista_de_listas_screen.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListasController>();
    final lista = controller.listaSelecionada;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const ListaDeListasScreen(),
      endDrawer: const ItensRecorrentesDrawer(),
      appBar: AppBar(
        title: Text(lista?.titulo ?? 'Mercado List'),
        actions: [
          IconButton(
            tooltip: 'Compartilhar lista',
            onPressed: controller.possuiItens
                ? () => context.mostrarInfo(
                      'O compartilhamento estará disponível em uma próxima '
                      'versão.',
                    )
                : null,
            icon: const Icon(PhosphorIcons.shareNetwork),
          ),
          IconButton(
            tooltip: 'Salvar no histórico',
            onPressed: controller.possuiItensMarcados
                ? () => _salvarNoHistorico(context, controller)
                : null,
            icon: const Icon(PhosphorIcons.clockCounterClockwise),
          ),
        ],
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: const ListaItensScreen(),
    );
  }

  Future<void> _salvarNoHistorico(
    BuildContext context,
    ListasController controller,
  ) async {
    try {
      await controller.salvarNoHistorico();
      if (context.mounted) {
        context.mostrarSucesso('Compra salva no histórico.');
      }
    } catch (erro) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível salvar: $erro');
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../core/extensions/snackbar_extension.dart';
import 'compartilhamento/service/compartilhamento_service.dart';
import 'compartilhamento/widget/compartilhamento_sheet.dart';
import 'itens/controller/itens_controller.dart';
import 'itens/screen/lista_itens_screen.dart';
import 'itens_recorrentes/screen/itens_recorrentes_drawer.dart';
import 'listas/controller/listas_controller.dart';
import 'listas/model/lista_model.dart';
import 'listas/screen/lista_de_listas_screen.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lista = context.select<ListasController, Lista?>(
      (controller) => controller.listaSelecionada,
    );
    final estadoItens = context.select<ItensController, (bool, bool)>(
      (controller) => (controller.possuiItens, controller.possuiItensMarcados),
    );
    final itensController = context.read<ItensController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: const ListaDeListasScreen(),
      endDrawer: const ItensRecorrentesDrawer(),
      appBar: AppBar(
        title: Text(lista?.titulo ?? 'Mercado List'),
        iconTheme: lista == null ? null : IconThemeData(color: lista.cor),
        actions: [
          Hero(
            tag: 'pesquisa-itens-hero',
            child: Material(
              type: MaterialType.transparency,
              child: IconButton(
                tooltip: 'Pesquisar itens',
                onPressed: estadoItens.$1
                    ? () => ListaItensScreen.abrirPesquisa(context)
                    : null,
                icon: Icon(
                  PhosphorIcons.magnifyingGlass,
                  color: estadoItens.$1 ? lista?.cor : null,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Compartilhar lista',
            onPressed: estadoItens.$1
                ? () => _compartilhar(context, itensController)
                : null,
            icon: Icon(
              PhosphorIcons.shareNetwork,
              color: estadoItens.$1 ? lista?.cor : null,
            ),
          ),
          IconButton(
            tooltip: 'Salvar no histórico',
            onPressed: estadoItens.$2
                ? () => _salvarNoHistorico(context, itensController)
                : null,
            icon: Icon(
              PhosphorIcons.clockCounterClockwise,
              color: estadoItens.$2 ? lista?.cor : null,
            ),
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
    ItensController controller,
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

  Future<void> _compartilhar(
    BuildContext context,
    ItensController controller,
  ) async {
    try {
      final conteudo = controller.prepararConteudoCompartilhamento();
      await CompartilhamentoSheet.exibir(
        context,
        conteudo: conteudo,
        corDestaque: controller.listaSelecionada!.cor,
        service: context.read<CompartilhamentoService>(),
      );
    } catch (erro) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível compartilhar: $erro');
      }
    }
  }
}

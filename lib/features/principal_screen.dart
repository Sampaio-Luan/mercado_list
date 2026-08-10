import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../core/constants/enums/tipo_dialogo.dart';
import '../core/extensions/snackbar_extension.dart';
import '../core/services/carregamento_service.dart';
import '../core/services/dialogo_service.dart';
import 'compartilhamento/service/compartilhamento_service.dart';
import 'compartilhamento/widget/compartilhamento_sheet.dart';
import 'historico/controller/historico_controller.dart';
import 'historico/form/historico_formulario.dart';
import 'historico/screen/historico_screen.dart';
import 'itens/controller/itens_controller.dart';
import 'itens/screen/lista_itens_screen.dart';
import 'itens_recorrentes/screen/itens_recorrentes_drawer.dart';
import 'listas/controller/listas_controller.dart';
import 'listas/model/lista_model.dart';
import 'listas/screen/lista_de_listas_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  bool _ofertaHistoricoAberta = false;

  @override
  Widget build(BuildContext context) {
    final lista = context.select<ListasController, Lista?>(
      (controller) => controller.listaSelecionada,
    );
    final estadoItens = context.select<ItensController, (bool, bool, bool)>(
      (controller) => (
        controller.possuiItens,
        controller.possuiItensMarcados,
        controller.salvandoHistorico,
      ),
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
                    ? () => ListaItensScreen.abrirPesquisa(
                          context,
                          aoConcluirLista: () =>
                              _oferecerSalvarListaConcluida(itensController),
                        )
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
            onPressed:
                estadoItens.$1 ? () => _compartilhar(itensController) : null,
            icon: Icon(
              PhosphorIcons.shareNetwork,
              color: estadoItens.$1 ? lista?.cor : null,
            ),
          ),
          IconButton(
            tooltip: 'Salvar no histórico',
            onPressed: estadoItens.$2 && !estadoItens.$3
                ? () => _salvarNoHistorico(itensController)
                : null,
            icon: Icon(
              PhosphorIcons.clockCounterClockwise,
              color: estadoItens.$2 && !estadoItens.$3 ? lista?.cor : null,
            ),
          ),
        ],
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: ListaItensScreen(
        aoConcluirLista: () => _oferecerSalvarListaConcluida(itensController),
      ),
    );
  }

  Future<void> _oferecerSalvarListaConcluida(
    ItensController controller,
  ) async {
    if (_ofertaHistoricoAberta ||
        controller.salvandoHistorico ||
        !controller.todosItensMarcados ||
        !mounted) {
      return;
    }
    _ofertaHistoricoAberta = true;
    try {
      final resultado = await DialogoService.mostrar(
        context: context,
        tipo: TipoDialogo.informacao,
        titulo: 'Lista concluída',
        mensagem: 'Todos os itens foram marcados. Deseja salvar esta compra '
            'no histórico e desmarcar os itens salvos para reutilizar a lista?',
        textoConfirmar: 'Salvar e reutilizar',
        textoCancelar: 'Agora não',
        exibirCancelar: true,
      );
      if (resultado == ResultadoDialogo.confirmar && mounted) {
        await _salvarNoHistorico(
          controller,
          reutilizarAutomaticamente: true,
        );
      }
    } finally {
      _ofertaHistoricoAberta = false;
    }
  }

  Future<void> _salvarNoHistorico(
    ItensController controller, {
    bool reutilizarAutomaticamente = false,
  }) async {
    final elegiveis = controller.quantidadeItensElegiveisHistorico;
    if (elegiveis == 0) {
      await DialogoService.mostrar(
        context: context,
        tipo: TipoDialogo.aviso,
        titulo: 'Itens necessários',
        mensagem: 'Somente itens marcados e com preço podem ser salvos no '
            'histórico. Informe o preço de ao menos um item marcado.',
        textoConfirmar: 'Entendi',
      );
      return;
    }

    final historicoController = context.read<HistoricoController>();
    final historico = await HistoricoFormulario.criar(
      context,
      historico: controller.prepararNovoHistorico(),
      quantidadeItens: elegiveis,
      quantidadeItensIgnorados: controller.quantidadeItensMarcadosSemPreco,
      sugestoesLojas: historicoController.sugestoesLojas,
    );
    if (historico == null || !mounted) return;

    try {
      await CarregamentoService.executar(
        context: context,
        titulo: 'Salvando compra',
        descricaoInicial: 'Preparando o histórico...',
        mensagemSucesso: 'Compra salva no histórico.',
        mensagemErro: 'Não foi possível salvar a compra.',
        duracaoMinima: const Duration(milliseconds: 1500),
        duracaoSucesso: const Duration(milliseconds: 1800),
        operacao: (atualizar) async {
          final salvo = await controller.salvarNoHistorico(
            historico,
            aoProgredir: atualizar,
          );
          await historicoController.carregar();
          return salvo;
        },
      );
    } catch (erro) {
      if (mounted) context.mostrarErro('Não foi possível salvar: $erro');
      return;
    }
    if (!mounted) return;

    if (reutilizarAutomaticamente) {
      await _desmarcarItensSalvos(controller);
    } else {
      await _oferecerDesmarcarItens(controller);
    }
    if (mounted) await _oferecerVisualizarHistorico();
  }

  Future<void> _oferecerDesmarcarItens(ItensController controller) async {
    final resultado = await DialogoService.mostrar(
      context: context,
      tipo: TipoDialogo.sucesso,
      titulo: 'Compra salva',
      mensagem: 'Deseja desmarcar os itens salvos para reutilizar esta lista?',
      textoConfirmar: 'Desmarcar itens',
      textoCancelar: 'Manter marcados',
      exibirCancelar: true,
    );
    if (resultado == ResultadoDialogo.confirmar && mounted) {
      await _desmarcarItensSalvos(controller);
    }
  }

  Future<void> _desmarcarItensSalvos(ItensController controller) async {
    try {
      await controller.desmarcarItensSalvosNoHistorico();
      if (mounted) {
        context.mostrarSucesso(
          'Os itens incluídos foram desmarcados para reutilização.',
        );
      }
    } catch (_) {
      if (mounted) {
        context.mostrarAviso(
          'A compra foi salva, mas os itens não puderam ser desmarcados.',
        );
      }
    }
  }

  Future<void> _oferecerVisualizarHistorico() async {
    final resultado = await DialogoService.mostrar(
      context: context,
      tipo: TipoDialogo.informacao,
      titulo: 'Histórico atualizado',
      mensagem: 'A compra já está disponível. Deseja visualizar o histórico?',
      textoConfirmar: 'Ver histórico',
      textoCancelar: 'Continuar na lista',
      exibirCancelar: true,
    );
    if (resultado != ResultadoDialogo.confirmar || !mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => HistoricoScreen(
          corDestaque: context.read<ItensController>().listaSelecionada?.cor,
        ),
      ),
    );
  }

  Future<void> _compartilhar(ItensController controller) async {
    try {
      final conteudo = controller.prepararConteudoCompartilhamento();
      await CompartilhamentoSheet.exibir(
        context,
        conteudo: conteudo,
        corDestaque: controller.listaSelecionada!.cor,
        service: context.read<CompartilhamentoService>(),
      );
    } catch (erro) {
      if (mounted) {
        context.mostrarErro('Não foi possível compartilhar: $erro');
      }
    }
  }
}

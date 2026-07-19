import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/extensions/dialogo_extension.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/model/progresso_operacao.dart';
import '../../../core/services/carregamento_service.dart';
import '../../../shared/widgets/menu_contexto/menu_contexto_exportacoes.dart';
import '../../../shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';
import '../../itens_recorrentes/form/item_recorrente_formulario.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../../itens_recorrentes/widget/item_recorrente_painel_widget.dart';
import '../../itens_recorrentes/widget/rodape_acoes_itens_recorrentes.dart';
import '../controller/categorias_controller.dart';
import '../form/categoria_formulario.dart';
import '../model/categoria_com_itens_recorrentes_model.dart';
import '../model/categoria_model.dart';

class CategoriaComItensRecorrentesWidget extends StatelessWidget {
  final CategoriaComItensRecorrentes categoriaComItensRecorrentes;
  final Categoria categoria;
  final List<ItemRecorrente> itensRecorrentes;
  CategoriaComItensRecorrentesWidget({
    super.key,
    required this.categoriaComItensRecorrentes,
  })  : categoria = categoriaComItensRecorrentes.categoria,
        itensRecorrentes = categoriaComItensRecorrentes.itensRecorrentes;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
        decoration: BoxDecoration(
          color: categoria.cor.withAlpha(15),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          spacing: 15,
          children: [
            Text(
              '${categoria.ordem}°',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: categoria.cor,
                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoria.titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(200),
                    ),
                  ),
                  Text(
                    '${itensRecorrentes.isEmpty ? "Sem itens" : itensRecorrentes.length == 1 ? "${itensRecorrentes.length} item" : "${itensRecorrentes.length} itens"} • id: ${categoria.id} •  ${categoria.categoriaPadrao ? '🔴' : '🟢'}',
                  ),
                  //Text(' • Ordem: ${categoria.ordem} • id: ${categoria.id}'),
                ],
              ),
            ),
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: categoria.cor.withAlpha(150),
              ),
              icon: Icon(
                PhosphorIcons.pencilLine,
                size: 25,
                color: Colors.white,
              ),
              onPressed: () async {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context)
                          .viewInsets
                          .bottom, // 2. Empurra o conteúdo para cima do teclado
                    ),
                    child: SingleChildScrollView(
                      child: CategoriaFormulario(
                        categoria: categoria,
                        quantidadeItens: itensRecorrentes.length,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      onTap: () => _abrirItensRecorrentes(context),
    );
  }

  Future<void> _abrirItensRecorrentes(BuildContext context) async {
    final categoriasController = context.read<CategoriasController>();

    await PainelPesquisa.exibir<ItemRecorrente>(
      context: context,
      itens: itensRecorrentes,
      obterTextoPesquisa: (item) => item.titulo,
      obterIdentificador: (item) => item.id ?? item,
      modoSelecao: ModoInteracaoPainel.multipla,
      titulo: categoria.titulo,
      textoPlaceholderPesquisa: 'Buscar por itens de ${categoria.titulo}...',
      textoListaVazia: 'Nenhum item recorrente nesta categoria.',
      exibirRodapeConfirmacao: false,
      gerenciarGestosItemCustomizado: false,
      fecharAoTocarFora: false,
      fecharAoArrastar: false,
      estilo: EstiloPainelPesquisa(
        corIconeSelecionado: categoria.cor,
        corItemSelecionado: categoria.cor,
        estiloTextoItemDestacado: TextStyle(
          color: categoria.cor,
          fontWeight: FontWeight.bold,
        ),
      ),
      construirRodape: (contextoPainel, controladorPainel) {
        final itensSelecionados = controladorPainel.itensSelecionados.toList();
        return RodapeAcoesItensRecorrentes(
          quantidadeSelecionada: itensSelecionados.length,
          aoAdicionar: () => _adicionarItemRecorrente(
            contextoPainel,
            categoriasController,
            controladorPainel,
          ),
          aoMover: () => _moverItensSelecionados(
            contextoPainel,
            categoriasController,
            controladorPainel,
            itensSelecionados,
          ),
          aoCriarCategoria: () => _criarCategoriaEMoverItens(
            contextoPainel,
            categoriasController,
            controladorPainel,
            itensSelecionados,
          ),
          aoExcluir: () => _excluirItensSelecionados(
            contextoPainel,
            categoriasController,
            controladorPainel,
            itensSelecionados,
          ),
        );
      },
      construirItem: (contextoItem, resultado) {
        final item = resultado.item;
        final card = ItemRecorrentePainelWidget(
          item: item,
          termoPesquisa: resultado.termoPesquisa,
          corCategoria: categoria.cor,
          selecionado: resultado.selecionado,
        );
        final menuContexto = MenuDeContexto(
          tema: TemaMenuContexto(
            glassmorphism: false,
            //blurCard: 10,
            //corFundo: categoria.cor.withAlpha(30),
            corBorda: Colors.transparent,
            largura: MediaQuery.of(contextoItem).size.width * .75,
          ),
          acoes: [
            AcaoMenuContexto(
              titulo: 'Editar',
              icone: PhosphorIcons.pencilLine,
              aoSelecionar: () async {
                final itemEditado = await ItemRecorrenteFormulario.exibir(
                  contextoItem,
                  idCategoria: item.idCategoria,
                  item: item,
                );
                if (itemEditado == null) return;

                try {
                  final itemSalvo = await categoriasController
                      .editarItemRecorrente(itemEditado);
                  resultado.atualizar(itemSalvo);
                  if (contextoItem.mounted) {
                    contextoItem.mostrarSucesso('Item editado com sucesso.');
                  }
                } catch (_) {
                  if (contextoItem.mounted) {
                    contextoItem.mostrarErro('Não foi possível editar o item.');
                  }
                }
              },
            ),
            AcaoMenuContexto(
              titulo: 'Mover para outra categoria',
              icone: PhosphorIcons.folderSimple,
              aoSelecionar: () async {
                final categoriasDestino = categoriasController
                    .categoriasComItensRecorrentes
                    .map((grupo) => grupo.categoria)
                    .where((outra) => outra.id != item.idCategoria)
                    .toList();
                final resposta = await PainelPesquisa.exibir<Categoria>(
                  context: contextoItem,
                  itens: categoriasDestino,
                  obterTextoPesquisa: (categoria) => categoria.titulo,
                  obterIdentificador: (categoria) => categoria.id,
                  modoSelecao: ModoInteracaoPainel.unica,
                  titulo: 'Mover para categoria',
                  textoPlaceholderPesquisa: 'Buscar categoria...',
                );
                final destino = resposta as Categoria?;
                if (destino == null) return;

                try {
                  await categoriasController.moverItemRecorrente(
                    item,
                    destino.id!,
                  );
                  resultado.remover();
                  if (contextoItem.mounted) {
                    contextoItem.mostrarSucesso(
                      'Item movido para ${destino.titulo}.',
                    );
                  }
                } catch (_) {
                  if (contextoItem.mounted) {
                    contextoItem.mostrarErro('Não foi possível mover o item.');
                  }
                }
              },
            ),
            AcaoMenuContexto(
              titulo: 'Excluir',
              icone: PhosphorIcons.trash,
              destrutivo: true,
              aoSelecionar: () async {
                final confirmacao = await contextoItem.confirmar(
                  titulo: 'Excluir item recorrente',
                  mensagem: 'Deseja excluir "${item.titulo}"?',
                  textoConfirmar: 'Excluir',
                );
                if (confirmacao != ResultadoDialogo.confirmar) return;

                try {
                  await categoriasController.excluirItemRecorrente(item);
                  resultado.remover();
                  if (contextoItem.mounted) {
                    contextoItem.mostrarSucesso('Item excluído com sucesso.');
                  }
                } catch (_) {
                  if (contextoItem.mounted) {
                    contextoItem.mostrarErro(
                      'Não foi possível excluir o item.',
                    );
                  }
                }
              },
            ),
          ],
          child: card,
        );

        final selecaoAtiva = resultado.controlador.itensSelecionados.isNotEmpty;
        return InteracaoItemMenuSelecao(
          selecaoAtiva: selecaoAtiva,
          aoAbrirMenu: () => menuContexto.abrir(contextoItem),
          aoAlternarSelecao: resultado.alternarSelecao,
          child: card,
        );
      },
    );
  }

  Future<void> _adicionarItemRecorrente(
    BuildContext context,
    CategoriasController categoriasController,
    ControladorPainelPesquisa<ItemRecorrente> controladorPainel,
  ) async {
    final item = await ItemRecorrenteFormulario.exibir(
      context,
      idCategoria: categoria.id!,
    );
    if (item == null) return;

    try {
      final itemCriado =
          await categoriasController.adicionarItemRecorrente(item);
      controladorPainel.adicionarItem(itemCriado);
      if (context.mounted) {
        context.mostrarSucesso('Item adicionado com sucesso.');
      }
    } catch (_) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível adicionar o item.');
      }
    }
  }

  Future<void> _moverItensSelecionados(
    BuildContext context,
    CategoriasController categoriasController,
    ControladorPainelPesquisa<ItemRecorrente> controladorPainel,
    List<ItemRecorrente> itensSelecionados,
  ) async {
    final categoriasDestino = categoriasController.categoriasComItensRecorrentes
        .map((grupo) => grupo.categoria)
        .where((outra) => outra.id != categoria.id)
        .toList();

    if (categoriasDestino.isEmpty) {
      context.mostrarAviso('Não há outra categoria disponível.');
      return;
    }

    final resposta = await PainelPesquisa.exibir<Categoria>(
      context: context,
      itens: categoriasDestino,
      obterTextoPesquisa: (categoria) => categoria.titulo,
      obterIdentificador: (categoria) => categoria.id,
      modoSelecao: ModoInteracaoPainel.unica,
      titulo: 'Mover ${itensSelecionados.length} selecionados',
      textoPlaceholderPesquisa: 'Buscar categoria...',
    );
    final destino = resposta as Categoria?;
    if (destino == null || !context.mounted) return;

    try {
      await CarregamentoService.executar<void>(
        context: context,
        titulo: 'Movendo itens recorrentes',
        descricaoInicial: 'Preparando a movimentação...',
        mensagemSucesso:
            '${itensSelecionados.length} itens movidos para ${destino.titulo}.',
        mensagemErro: 'Não foi possível mover os itens selecionados.',
        duracaoMinima: const Duration(seconds: 5),
        operacao: (atualizar) async {
          atualizar(
            const ProgressoOperacao(
              etapa: 1,
              total: 3,
              descricao: 'Validando os itens selecionados...',
            ),
          );
          atualizar(
            ProgressoOperacao(
              etapa: 2,
              total: 3,
              descricao: 'Movendo para ${destino.titulo}...',
            ),
          );
          await categoriasController.moverItensRecorrentes(
            itensSelecionados,
            destino.id!,
          );
          atualizar(
            const ProgressoOperacao(
              etapa: 3,
              total: 3,
              descricao: 'Atualizando a lista de itens...',
            ),
          );
          for (final item in itensSelecionados) {
            controladorPainel.removerItem(item);
          }
          controladorPainel.limparSelecao();
        },
      );
    } catch (_) {
      // O serviço de carregamento mantém o erro visível até o usuário fechar.
    }
  }

  Future<void> _criarCategoriaEMoverItens(
    BuildContext context,
    CategoriasController categoriasController,
    ControladorPainelPesquisa<ItemRecorrente> controladorPainel,
    List<ItemRecorrente> itensSelecionados,
  ) async {
    final novaCategoria = await CategoriaFormulario.exibirParaResultado(
      context,
    );
    if (novaCategoria == null || !context.mounted) return;

    try {
      await CarregamentoService.executar<void>(
        context: context,
        titulo: 'Criando categoria',
        descricaoInicial: 'Preparando a nova categoria...',
        mensagemSucesso:
            'Categoria ${novaCategoria.titulo} criada e itens movidos.',
        mensagemErro: 'Não foi possível concluir a criação da categoria.',
        duracaoMinima: const Duration(seconds: 5),
        operacao: (atualizar) async {
          atualizar(
            const ProgressoOperacao(
              etapa: 1,
              total: 4,
              descricao: 'Validando os dados da categoria...',
            ),
          );
          atualizar(
            const ProgressoOperacao(
              etapa: 2,
              total: 4,
              descricao: 'Criando a nova categoria...',
            ),
          );
          final categoriaCriada =
              await categoriasController.criarCategoria(novaCategoria);
          atualizar(
            const ProgressoOperacao(
              etapa: 3,
              total: 4,
              descricao: 'Movendo os itens selecionados...',
            ),
          );
          await categoriasController.moverItensRecorrentes(
            itensSelecionados,
            categoriaCriada.id!,
          );
          atualizar(
            const ProgressoOperacao(
              etapa: 4,
              total: 4,
              descricao: 'Atualizando as categorias...',
            ),
          );
          for (final item in itensSelecionados) {
            controladorPainel.removerItem(item);
          }
          controladorPainel.limparSelecao();
        },
      );
    } catch (_) {
      // O serviço de carregamento mantém o erro visível até o usuário fechar.
    }
  }

  Future<void> _excluirItensSelecionados(
    BuildContext context,
    CategoriasController categoriasController,
    ControladorPainelPesquisa<ItemRecorrente> controladorPainel,
    List<ItemRecorrente> itensSelecionados,
  ) async {
    final confirmacao = await context.confirmar(
      titulo: 'Excluir itens recorrentes',
      mensagem: 'Deseja excluir ${itensSelecionados.length} '
          'item${itensSelecionados.length == 1 ? '' : 's'} selecionado${itensSelecionados.length == 1 ? '' : 's'}?',
      textoConfirmar: 'Excluir',
    );
    if (confirmacao != ResultadoDialogo.confirmar || !context.mounted) return;

    try {
      await CarregamentoService.executar<void>(
        context: context,
        titulo: 'Excluindo itens recorrentes',
        descricaoInicial: 'Preparando a exclusão...',
        mensagemSucesso: 'Itens selecionados excluídos.',
        mensagemErro: 'Não foi possível excluir os itens selecionados.',
        duracaoMinima: const Duration(seconds: 5),
        operacao: (atualizar) async {
          atualizar(
            const ProgressoOperacao(
              etapa: 1,
              total: 3,
              descricao: 'Validando os itens selecionados...',
            ),
          );
          atualizar(
            const ProgressoOperacao(
              etapa: 2,
              total: 3,
              descricao: 'Excluindo os itens recorrentes...',
            ),
          );
          await categoriasController.excluirItensRecorrentes(
            itensSelecionados,
          );
          atualizar(
            const ProgressoOperacao(
              etapa: 3,
              total: 3,
              descricao: 'Atualizando a lista de itens...',
            ),
          );
          for (final item in itensSelecionados) {
            controladorPainel.removerItem(item);
          }
          controladorPainel.limparSelecao();
        },
      );
    } catch (_) {
      // O serviço de carregamento mantém o erro visível até o usuário fechar.
    }
  }
}

import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/extensions/dialogo_extension.dart';
import '../../../core/services/carregamento_service.dart';
import '../../../shared/widgets/bottom_sheet_pesquisa/bottom_sheet_pesquisa_generica_exportacoes.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';
import '../form/categoria_formulario.dart';
import '../controller/categorias_controller.dart';
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
                    '${itensRecorrentes.isEmpty ? "Sem itens" : itensRecorrentes.length == 1 ? "${itensRecorrentes.length} item" : "${itensRecorrentes.length} itens"} • Ordem: ${categoria.ordem} • id: ${categoria.id} •  ${categoria.categoriaPadrao ? '🔴' : '🟢'}',
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
                      child: CategoriaFormulario(categoria: categoria),
                    ),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: categoria.categoriaPadrao
                  ? 'A categoria padrão não pode ser excluída'
                  : 'Excluir categoria',
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              ),
              icon: Icon(
                PhosphorIcons.trash,
                size: 25,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              onPressed: categoria.categoriaPadrao
                  ? null
                  : () => _confirmarExclusao(context),
            ),
          ],
        ),
      ),
      onTap: () {
        BottomSheetPesquisaGenerica.exibir<ItemRecorrente>(
          context: context,
          itens: itensRecorrentes,
          obterTextoExibicao: (item) => item.titulo,
          obterTextoSubtitulo: (item) =>
              '${item.idCategoria} • ${item.tipoMedida.name}',
          modoSelecao: ModoSelecao.multipla,
          itensSelecionadosInicialmente: [],
          titulo: categoria.titulo,
          textoPlaceholderPesquisa:
              'Buscar por itens de ${categoria.titulo}...',
          textoBotaoConfirmar: 'Confirmar seleção',
          // construirIconeLideranca: (item) => CircleAvatar(
          //   radius: 16,
          //   child: Text(
          //     item.titulo,
          //     style: const TextStyle(
          //       fontSize: 11,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          estilo: EstiloBottomSheetPesquisa(
            corIconeSelecionado: categoria.cor,
            corItemSelecionado: categoria.cor.withAlpha(20),
            estiloTextoItemDestacado: TextStyle(
              color: categoria.cor,
              fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmarExclusao(BuildContext context) async {
    final resultado = await context.confirmar(
      titulo: 'Excluir categoria',
      mensagem: 'Os itens recorrentes de "${categoria.titulo}" serão movidos '
          'para a categoria padrão. Deseja continuar?',
      textoConfirmar: 'Excluir',
    );

    if (resultado != ResultadoDialogo.confirmar || !context.mounted) {
      return;
    }

    final controller = context.read<CategoriasController>();

    try {
      await CarregamentoService.executar<void>(
        context: context,
        titulo: 'Excluindo categoria',
        mensagemSucesso: 'Categoria excluída com sucesso.',
        mensagemErro:
            'Não foi possível excluir a categoria. Nenhuma alteração foi aplicada.',
        operacao: (atualizar) => controller.excluir(
          categoria,
          aoProgredir: atualizar,
        ),
      );
    } catch (_) {
      // O Controller registra o erro e o card apresenta o feedback ao usuário.
    }
  }
}

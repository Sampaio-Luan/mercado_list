import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/cor_contraste_extension.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';
import '../controller/categorias_controller.dart';
import '../form/categoria_formulario.dart';
import '../model/categoria_model.dart';

@immutable
class ResultadoSelecaoCategoria {
  final Categoria? categoria;
  final bool todas;

  const ResultadoSelecaoCategoria.categoria(Categoria this.categoria)
      : todas = false;

  const ResultadoSelecaoCategoria.todas()
      : categoria = null,
        todas = true;

  int? get idCategoria => categoria?.id;

  String get titulo => todas ? 'Todas as categorias' : categoria!.titulo;
}

abstract final class SeletorCategoria {
  static Future<ResultadoSelecaoCategoria?> exibir(
    BuildContext context, {
    required List<Categoria> categorias,
    int? idSelecionado,
    Color? corDestaque,
    bool permitirTodas = false,
    bool permitirCriar = false,
    Set<int> idsCategoriasExcluidas = const {},
    String titulo = 'Selecionar categoria',
    String textoPlaceholderPesquisa = 'Pesquisar categoria...',
  }) async {
    final opcoes = <ResultadoSelecaoCategoria>[
      if (permitirTodas) const ResultadoSelecaoCategoria.todas(),
      for (final categoria in categorias)
        if (categoria.id == null ||
            !idsCategoriasExcluidas.contains(categoria.id))
          ResultadoSelecaoCategoria.categoria(categoria),
    ];
    final selecionadaInicialmente = opcoes.where((opcao) {
      return opcao.todas
          ? permitirTodas && idSelecionado == null
          : opcao.idCategoria == idSelecionado;
    }).toList(growable: false);
    final temaBase = Theme.of(context);
    final cor = (corDestaque ?? temaBase.colorScheme.primary)
        .paraPrimeiroPlano(temaBase);

    final resposta = await PainelPesquisa.exibir<ResultadoSelecaoCategoria>(
      context: context,
      itens: opcoes,
      obterTextoPesquisa: (opcao) => opcao.titulo,
      obterIdentificador: (opcao) =>
          opcao.todas ? #todasCategorias : opcao.idCategoria ?? opcao.categoria,
      modoSelecao: ModoInteracaoPainel.unica,
      itensSelecionadosInicialmente: selecionadaInicialmente,
      titulo: titulo,
      textoPlaceholderPesquisa: textoPlaceholderPesquisa,
      textoListaVazia: 'Nenhuma categoria disponível.',
      textoSemResultados: 'Nenhuma categoria encontrada.',
      obterTextoSubtitulo: (opcao) =>
          opcao.categoria?.categoriaPadrao == true ? 'Categoria padrão' : null,
      construirIconeLideranca: (opcao) {
        if (opcao.todas) return const Icon(PhosphorIcons.stack);
        return CircleAvatar(
          radius: 8,
          backgroundColor: opcao.categoria!.cor,
        );
      },
      construirAcoesCabecalho: permitirCriar
          ? (contextoPainel, controlador) => [
                IconButton.filledTonal(
                  tooltip: 'Criar categoria',
                  onPressed: () => _criarCategoria(
                    contextoPainel,
                    controlador,
                  ),
                  icon: const Icon(PhosphorIcons.plus),
                ),
              ]
          : null,
      estilo: EstiloPainelPesquisa(
        corItemSelecionado: cor.withAlpha(24),
        corIconeSelecionado: cor,
      ),
      tema: temaBase.copyWith(
        colorScheme: temaBase.colorScheme.copyWith(
          primary: cor,
          secondary: cor,
        ),
      ),
    );

    return resposta as ResultadoSelecaoCategoria?;
  }

  static Future<void> _criarCategoria(
    BuildContext context,
    ControladorPainelPesquisa<ResultadoSelecaoCategoria> controlador,
  ) async {
    final nova = await CategoriaFormulario.exibirParaResultado(context);
    if (nova == null || !context.mounted) return;

    try {
      final criada =
          await context.read<CategoriasController>().criarCategoria(nova);
      final resultado = ResultadoSelecaoCategoria.categoria(criada);
      controlador.adicionarItem(resultado);
      if (context.mounted) Navigator.pop(context, resultado);
    } catch (_) {
      if (context.mounted) {
        context.mostrarErro('Não foi possível criar a categoria.');
      }
    }
  }
}

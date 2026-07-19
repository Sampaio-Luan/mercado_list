import 'dart:async';

import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../controller/categorias_controller.dart';
import '../form/categoria_formulario.dart';
import '../widget/categoria_com_itens_recorrentes_widget.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  static const _duracaoAviso = Duration(seconds: 15);
  static const _duracaoAnimacao = Duration(milliseconds: 300);

  Timer? _temporizadorAviso;
  bool _avisoVisivel = true;
  bool _iconeAvisoDisponivel = false;
  bool _avisoReabertoPeloUsuario = false;
  bool _ordenandoAlfabeticamente = false;

  @override
  void initState() {
    super.initState();
    _agendarOcultacaoAviso();
  }

  @override
  void dispose() {
    _temporizadorAviso?.cancel();
    super.dispose();
  }

  void _agendarOcultacaoAviso() {
    _temporizadorAviso?.cancel();
    _temporizadorAviso = Timer(_duracaoAviso, () {
      if (!mounted) return;
      setState(() {
        _avisoVisivel = false;
        _iconeAvisoDisponivel = true;
        _avisoReabertoPeloUsuario = false;
      });
    });
  }

  void _reexibirAviso() {
    setState(() {
      _avisoVisivel = true;
      _avisoReabertoPeloUsuario = true;
    });
    _agendarOcultacaoAviso();
  }

  void _dispensarAviso() {
    _temporizadorAviso?.cancel();
    setState(() {
      _avisoVisivel = false;
      _avisoReabertoPeloUsuario = false;
    });
  }

  Future<void> _ordenarAlfabeticamente() async {
    if (_ordenandoAlfabeticamente) return;
    setState(() => _ordenandoAlfabeticamente = true);
    try {
      await context.read<CategoriasController>().ordenarAlfabeticamente();
      if (mounted) context.mostrarSucesso('Categorias ordenadas de A a Z.');
    } catch (_) {
      if (mounted) {
        context.mostrarErro('Não foi possível ordenar as categorias.');
      }
    } finally {
      if (mounted) setState(() => _ordenandoAlfabeticamente = false);
    }
  }

  Future<void> _reordenar(int indiceAntigo, int indiceNovo) async {
    try {
      await context
          .read<CategoriasController>()
          .reordenar(indiceAntigo, indiceNovo);
    } catch (_) {
      if (mounted) {
        context.mostrarErro(
          'Não foi possível salvar a nova ordem das categorias.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final alterandoOrdem = context.watch<CategoriasController>().alterandoOrdem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: tema.colorScheme.surface,
        centerTitle: true,
        actions: [
          IconButton(
            key: const ValueKey('acao-ordenar-categorias'),
            tooltip: 'Ordenar categorias de A a Z',
            onPressed: _ordenandoAlfabeticamente || alterandoOrdem
                ? null
                : _ordenarAlfabeticamente,
            icon: Icon(PhosphorIcons.sortAscending),
          ),
          AnimatedSwitcher(
            duration: _duracaoAnimacao,
            child: !_iconeAvisoDisponivel
                ? const SizedBox(
                    key: ValueKey('espaco-aviso-reordenacao'),
                    width: 48,
                  )
                : IconButton(
                    key: const ValueKey('acao-aviso-reordenacao'),
                    tooltip: 'Como reordenar categorias',
                    onPressed: _reexibirAviso,
                    icon: Icon(
                      PhosphorIcons.info,
                      color: tema.colorScheme.tertiary,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: _duracaoAnimacao,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.topCenter,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _avisoVisivel
                ? _AvisoReordenacaoCategorias(
                    permitirDispensar: _avisoReabertoPeloUsuario,
                    aoDispensar: _dispensarAviso,
                  )
                : const SizedBox.shrink(
                    key: ValueKey('aviso-reordenacao-oculto'),
                  ),
          ),
          Consumer<CategoriasController>(
            builder: (context, ref, _) {
              return Expanded(
                child: switch (ref.estado) {
                  EstadoDeTela.carregando => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  EstadoDeTela.erro => _EstadoCategorias(
                      icone: PhosphorIcons.warningCircle,
                      mensagem: ref.mensagemErro ??
                          'Não foi possível carregar as categorias.',
                      textoAcao: 'Tentar novamente',
                      aoAcionar: ref.carregar,
                    ),
                  EstadoDeTela.carregadaSemDados => _EstadoCategorias(
                      icone: PhosphorIcons.folderOpen,
                      mensagem: 'Nenhuma categoria encontrada.',
                      textoAcao: 'Recarregar',
                      aoAcionar: ref.carregar,
                    ),
                  EstadoDeTela.carregadaComDados => ReorderableListView.builder(
                      padding: const EdgeInsets.all(5),
                      buildDefaultDragHandles: true,
                      itemCount: ref.categoriasComItensRecorrentes.length,
                      onReorderItem: _reordenar,
                      itemBuilder: (context, index) {
                        return CategoriaComItensRecorrentesWidget(
                          key: ValueKey(
                            ref.categoriasComItensRecorrentes[index].categoria
                                .id,
                          ),
                          categoriaComItensRecorrentes:
                              ref.categoriasComItensRecorrentes[index],
                        );
                      },
                    ),
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              spacing: 15,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: alterandoOrdem
                        ? null
                        : () {
                            showModalBottomSheet<void>(
                              isScrollControlled: true,
                              context: context,
                              builder: (context) => Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: const SingleChildScrollView(
                                  child: CategoriaFormulario(),
                                ),
                              ),
                            );
                          },
                    icon: Icon(PhosphorIcons.stackPlusBold),
                    label: Text('Add Categoria'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoCategorias extends StatelessWidget {
  final IconData icone;
  final String mensagem;
  final String textoAcao;
  final Future<void> Function() aoAcionar;

  const _EstadoCategorias({
    required this.icone,
    required this.mensagem,
    required this.textoAcao,
    required this.aoAcionar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(icone, size: 40, color: cores.secondary),
            Text(mensagem, textAlign: TextAlign.center),
            OutlinedButton.icon(
              onPressed: aoAcionar,
              icon: Icon(PhosphorIcons.arrowClockwise),
              label: Text(textoAcao),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvisoReordenacaoCategorias extends StatelessWidget {
  final bool permitirDispensar;
  final VoidCallback aoDispensar;

  const _AvisoReordenacaoCategorias({
    required this.permitirDispensar,
    required this.aoDispensar,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Material(
      key: const ValueKey('aviso-reordenacao-visivel'),
      color: cores.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          spacing: 12,
          children: [
            Icon(
              PhosphorIcons.info,
              color: cores.onTertiaryContainer,
            ),
            Expanded(
              child: Text(
                'Pressione e arraste para reordenar',
                style: TextStyle(color: cores.onTertiaryContainer),
              ),
            ),
            if (permitirDispensar)
              IconButton(
                tooltip: 'Dispensar aviso',
                onPressed: aoDispensar,
                icon: Icon(
                  PhosphorIcons.x,
                  color: cores.onTertiaryContainer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/utils/texto_utils.dart';
import '../../categoria/controller/categorias_controller.dart';
import '../../categoria/form/categoria_formulario.dart';
import '../../categoria/model/categoria_model.dart';

class SeletorCategoriaModal extends StatefulWidget {
  final List<Categoria> categorias;
  final int? idSelecionado;
  final Color corDestaque;
  final bool permitirTodas;
  final bool permitirCriar;

  const SeletorCategoriaModal({
    super.key,
    required this.categorias,
    required this.idSelecionado,
    required this.corDestaque,
    this.permitirTodas = false,
    this.permitirCriar = false,
  });

  static Future<int?> exibir(
    BuildContext context, {
    required List<Categoria> categorias,
    required int? idSelecionado,
    required Color corDestaque,
    bool permitirTodas = false,
    bool permitirCriar = false,
  }) {
    final tema = Theme.of(context);
    final temaComDestaque = tema.copyWith(
      colorScheme: tema.colorScheme.copyWith(
        primary: corDestaque,
        secondary: corDestaque,
      ),
    );
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Theme(
        data: temaComDestaque,
        child: FractionallySizedBox(
          heightFactor: .78,
          child: SeletorCategoriaModal(
            categorias: categorias,
            idSelecionado: idSelecionado,
            corDestaque: corDestaque,
            permitirTodas: permitirTodas,
            permitirCriar: permitirCriar,
          ),
        ),
      ),
    );
  }

  @override
  State<SeletorCategoriaModal> createState() => _SeletorCategoriaModalState();
}

class _SeletorCategoriaModalState extends State<SeletorCategoriaModal> {
  String _pesquisa = '';

  @override
  Widget build(BuildContext context) {
    final termo = TextoUtils.normalizarParaOrdenacao(_pesquisa);
    final categorias = widget.categorias.where((categoria) {
      return termo.isEmpty ||
          TextoUtils.normalizarParaOrdenacao(categoria.titulo).contains(termo);
    }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Selecionar categoria',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (widget.permitirCriar)
                IconButton.filledTonal(
                  tooltip: 'Criar categoria',
                  onPressed: _criarCategoria,
                  icon: const Icon(PhosphorIcons.plus),
                ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                tooltip: 'Fechar',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(PhosphorIcons.x),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            key: const ValueKey('pesquisa-categorias-item'),
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Pesquisar categoria',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass),
            ),
            onChanged: (valor) => setState(() => _pesquisa = valor),
          ),
        ),
        const Divider(height: 1, thickness: .1),
        Expanded(
          child: categorias.isEmpty
              ? const Center(child: Text('Nenhuma categoria encontrada.'))
              : ListView.builder(
                  itemCount: categorias.length + (widget.permitirTodas ? 1 : 0),
                  itemBuilder: (context, indice) {
                    if (widget.permitirTodas && indice == 0) {
                      return ListTile(
                        leading: const Icon(PhosphorIcons.stack),
                        title: const Text('Todas as categorias'),
                        selected: widget.idSelecionado == null,
                        selectedTileColor: widget.corDestaque.withAlpha(24),
                        trailing: widget.idSelecionado == null
                            ? Icon(
                                PhosphorIcons.checkCircle,
                                color: widget.corDestaque,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, 0),
                      );
                    }
                    final indiceCategoria =
                        indice - (widget.permitirTodas ? 1 : 0);
                    final categoria = categorias[indiceCategoria];
                    final selecionada = categoria.id == widget.idSelecionado;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 8,
                        backgroundColor: categoria.cor,
                      ),
                      title: Text(categoria.titulo),
                      subtitle: categoria.categoriaPadrao
                          ? const Text('Categoria padrão')
                          : null,
                      selected: selecionada,
                      selectedTileColor: widget.corDestaque.withAlpha(24),
                      trailing: selecionada
                          ? Icon(
                              PhosphorIcons.checkCircle,
                              color: widget.corDestaque,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, categoria.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _criarCategoria() async {
    final nova = await CategoriaFormulario.exibirParaResultado(context);
    if (nova == null || !mounted) return;
    try {
      final criada =
          await context.read<CategoriasController>().criarCategoria(nova);
      if (mounted) Navigator.pop(context, criada.id);
    } catch (_) {
      if (mounted) context.mostrarErro('Não foi possível criar a categoria.');
    }
  }
}

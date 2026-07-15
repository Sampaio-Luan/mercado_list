import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../controller/categorias_controller.dart';
import '../form/categoria_formulario.dart';
import '../widget/categoria_com_itens_recorrentes_widget.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: tema.colorScheme.surface,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            child: Row(
              spacing: 15,
              children: [
                Icon(Icons.info_outline, color: Colors.deepOrange),

                Expanded(
                  child: Text(
                    'Pressione e arraste a categoria desejada para reordená-la e definir a ordem de exibição nas suas lista de compras.',

                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),

          Consumer<CategoriasController>(
            builder: (context, ref, _) {
              return Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(5),
                  buildDefaultDragHandles: true,
                  itemCount: ref.categoriasComItensRecorrentes.length,
                  onReorderItem: ref.reordenar,
                  itemBuilder: (context, index) {
                    return CategoriaComItensRecorrentesWidget(
                      key: ValueKey(
                        ref.categoriasComItensRecorrentes[index].categoria.id,
                      ),
                      categoriaComItensRecorrentes:
                          ref.categoriasComItensRecorrentes[index],
                    );
                  },
                ),
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

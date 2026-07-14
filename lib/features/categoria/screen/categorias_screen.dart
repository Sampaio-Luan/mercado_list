import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/constants/enums/tipo_snackbar.dart';
import '../../../core/services/dialogo_service.dart';
import '../../../core/services/snackbar_service.dart';
import '../../itens_recorrentes/model/item_recorrente_module.dart';
import '../controller/categorias_controller.dart';
import '../form/categoria_formulario.dart';
import '../model/categoria_model.dart';
import '../widget/categoria_com_itens_recorrentes_widget.dart';



class CategoriasScreen extends StatefulWidget {

  const CategoriasScreen({
    super.key
  });

  @override
  State<CategoriasScreen> createState() => _OrdenarCategoriasScreenState();
}

class _OrdenarCategoriasScreenState extends State<CategoriasScreen> {
  late List<Categoria> _categorias;

  bool _houveAlteracao = false;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();

  }

  Future<void> _salvar() async {
    try {
      setState(() {
        _salvando = true;
      });

      for (var i = 0; i < _categorias.length; i++) {
        _categorias[i].ordem = i;
      }

      //await widget.repository.atualizarOrdem(_categorias);

      if (!mounted) return;

      setState(() {
        _houveAlteracao = false;
      });

      SnackbarService.mostrar(
        context: context,
        mensagem: 'Ordem das categorias atualizada.',
        tipo: TipoSnackbar.sucesso,
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarService.mostrar(
        context: context,
        mensagem: 'Erro ao salvar: $e',
        tipo: TipoSnackbar.erro,
      );
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

 List<ItemRecorrente> itensRecorrentes = [
    ItemRecorrente.padrao(idCategoria: 1),
 ];

  void _reordenar(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final item = _categorias.removeAt(oldIndex);

      _categorias.insert(newIndex, item);

      _houveAlteracao = true;
    });
  }

  Future<bool> _confirmarSaida() async {
    final resultado = await DialogoService.mostrar(
      context: context,
      tipo: TipoDialogo.aviso,
      titulo: 'Atenção !',
      mensagem: 'As alterações feitas não foram salvas.\nO que deseja fazer?',
      exibirCancelar: true,
      textoConfirmar: 'Salvar, e sair',
      textoCancelar: 'Sair',
    );

    return resultado == ResultadoDialogo.confirmar ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return PopScope(
      canPop: !_houveAlteracao,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final sair = await _confirmarSaida();
        // sair = true salvar e sair
        // sair = false sair sem salvar
        if (sair) {
          await _salvar();
        }
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciar Categorias'),
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: tema.colorScheme.surface,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(PhosphorIcons.caretLeftBold),
            color: tema.colorScheme.onSurface,
            onPressed: () async {
              final sair = await _confirmarSaida();
              // sair = true salvar e sair
              // sair = false sair sem salvar
              if (sair) {
                await _salvar();
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
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
                      //style: const TextStyle(te),
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
                    itemCount: ref.categoriasService.categoriasComItensRecorrentes.length,
                    onReorderItem: _reordenar,
                    itemBuilder: (context, index) {

                      return CategoriaComItensRecorrentesWidget(
                        key: ValueKey(ref.categoriasService.categoriasComItensRecorrentes[index].categoria.id),
                        categoriaComItensRecorrentes:
                           ref.categoriasService.categoriasComItensRecorrentes[index],
                      );
                    },
                  ),
                );
              },
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 15,
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: !_houveAlteracao || _salvando
                            ? null
                            : _salvar,
                        icon: _salvando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: Text(_salvando ? 'Salvando...' : 'Salvar Ordem'),
                      ),
                    ),
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
                        icon: Icon( PhosphorIcons.stackPlusBold),
                        label: Text('Add Categoria'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

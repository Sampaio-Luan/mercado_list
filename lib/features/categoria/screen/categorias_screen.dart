import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/constants/enums/tipo_snackbar.dart';
import '../../../core/services/dialogo_service.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../shared/widgets/bottom_sheet_pesquisa/bottom_sheet_pesquisa_generica_exportacoes.dart';
import '../../itens_recorrentes/model/item_recorrente.module.dart';
import '../model/categoria_model.dart';
import '../repository/categoria_repository.dart';

import 'categoria.form.dart';



class CategoriasScreen extends StatefulWidget {
  final List<Categoria> categorias;
  final CategoriaRepository repository;

  const CategoriasScreen({
    super.key,
    required this.categorias,
    required this.repository,
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

    _categorias = [...widget.categorias]
      ..sort((a, b) => a.ordem.compareTo(b.ordem));
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
    //final itensRecorrentesR = context.watch<ItemRecorrenteRepository>();
    final List<ItemRecorrente> itensSelecionados = [];

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

            Consumer<CategoriaRepository>(
              builder: (context, ref, _) {
                return Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.all(5),
                    buildDefaultDragHandles: true,
                    itemCount: 18,
                    onReorderItem: _reordenar,
                    itemBuilder: (context, index) {
                      final categoria = _categorias[index];

                      return InkWell(
                        key: ValueKey(categoria.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          margin: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: categoria.cor.withAlpha(15),
                            borderRadius: BorderRadius.circular(5),
                          ),

                          child: Row(
                            spacing: 15,
                            children: [
                              Text(
                                '${index + 1}°',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: categoria.cor,
                                  fontSize: Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.fontSize,
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
                                    // Text(
                                    //   '${itensRecorrentesR.itensRecorrentesPorCategoria[categoria.id]!.isEmpty ? "Sem itens" : itensRecorrentesR.itensRecorrentesPorCategoria[categoria.id]!.length == 1 ? "${itensRecorrentesR.itensRecorrentesPorCategoria[categoria.id]!.length} item" : "${itensRecorrentesR.itensRecorrentesPorCategoria[categoria.id]!.length} itens"} • Ordem: ${categoria.ordem} • id: ${categoria.id}',
                                    // ),
                                    Text(' • Ordem: ${categoria.ordem} • id: ${categoria.id}')
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
                                        child: CategoriaForm(
                                          categoria: categoria,
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                            itensSelecionadosInicialmente: itensSelecionados,
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
                                fontSize: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
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
                                child: CategoriaForm(),
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

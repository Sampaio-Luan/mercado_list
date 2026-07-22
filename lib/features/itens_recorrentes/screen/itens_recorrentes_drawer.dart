import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/utils/texto_utils.dart';
import '../../itens/model/item_model.dart';
import '../../itens/widget/seletor_categoria_modal.dart';
import '../../listas/controller/listas_controller.dart';
import '../model/item_recorrente_model.dart';
import '../widget/item_recorrente_painel_widget.dart';

enum _SituacaoRecorrente { todos, naLista, foraDaLista }

class ItensRecorrentesDrawer extends StatefulWidget {
  const ItensRecorrentesDrawer({super.key});

  @override
  State<ItensRecorrentesDrawer> createState() => _ItensRecorrentesDrawerState();
}

class _ItensRecorrentesDrawerState extends State<ItensRecorrentesDrawer> {
  final _pesquisa = TextEditingController();
  final _mensageiro = GlobalKey<ScaffoldMessengerState>();
  final Set<int> _alterando = {};
  int? _idCategoria;
  _SituacaoRecorrente _situacao = _SituacaoRecorrente.todos;

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListasController>();
    final lista = controller.listaSelecionada;
    final categorias = {
      for (final categoria in controller.categorias) categoria.id: categoria,
    };
    final categoriaSelecionada = categorias[_idCategoria];
    final termo = TextoUtils.normalizarParaOrdenacao(_pesquisa.text);
    final itens = controller.itensRecorrentes.where((item) {
      final estaNaLista = controller.localizarDuplicado(item.titulo) != null;
      if (_idCategoria != null && item.idCategoria != _idCategoria) {
        return false;
      }
      if (_situacao == _SituacaoRecorrente.naLista && !estaNaLista) {
        return false;
      }
      if (_situacao == _SituacaoRecorrente.foraDaLista && estaNaLista) {
        return false;
      }
      return termo.isEmpty ||
          TextoUtils.normalizarParaOrdenacao(item.titulo).contains(termo);
    }).toList();
    final largura = MediaQuery.sizeOf(context).width * .70;
    final corLista = lista?.cor ?? Theme.of(context).colorScheme.primary;

    return Drawer(
      width: largura,
      child: ScaffoldMessenger(
        key: _mensageiro,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 6),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.repeat, color: corLista),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Itens recorrentes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Fechar',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(PhosphorIcons.x),
                      ),
                    ],
                  ),
                ),
                Padding(
                  key: const ValueKey('cabecalho-fixo-itens-recorrentes'),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: TextField(
                    key: const ValueKey('pesquisa-itens-recorrentes'),
                    controller: _pesquisa,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar itens recorrentes',
                      prefixIcon: const Icon(PhosphorIcons.magnifyingGlass),
                      suffixIcon: _pesquisa.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar pesquisa',
                              onPressed: () {
                                _pesquisa.clear();
                                setState(() {});
                              },
                              icon: const Icon(PhosphorIcons.x),
                            ),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<_SituacaoRecorrente>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: _SituacaoRecorrente.todos,
                          label: Text('Todos'),
                        ),
                        ButtonSegment(
                          value: _SituacaoRecorrente.naLista,
                          label: Text('Na lista'),
                        ),
                        ButtonSegment(
                          value: _SituacaoRecorrente.foraDaLista,
                          label: Text('Fora'),
                        ),
                      ],
                      selected: {_situacao},
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (estados) => estados.contains(WidgetState.selected)
                              ? corLista
                              : null,
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (estados) => estados.contains(WidgetState.selected)
                              ? _corSobre(corLista)
                              : null,
                        ),
                      ),
                      onSelectionChanged: (valor) {
                        setState(() => _situacao = valor.first);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _selecionarCategoria(
                        controller,
                        corLista,
                      ),
                      icon: Icon(
                        PhosphorIcons.tag,
                        color: categoriaSelecionada?.cor,
                      ),
                      label: Text(_tituloCategoria(controller)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        backgroundColor:
                            categoriaSelecionada?.cor.withAlpha(34),
                        side: BorderSide(
                          color: categoriaSelecionada?.cor.withAlpha(130) ??
                              Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: .1),
                Expanded(
                  child: ClipRect(
                    child: lista == null
                        ? const Center(child: Text('Selecione uma lista.'))
                        : itens.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'Nenhum item recorrente corresponde aos filtros.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                key: const ValueKey(
                                  'lista-rolavel-itens-recorrentes',
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                itemCount: itens.length,
                                itemBuilder: (context, indice) {
                                  final item = itens[indice];
                                  final existente = controller
                                      .localizarDuplicado(item.titulo);
                                  final categoria =
                                      categorias[item.idCategoria];
                                  final alterando =
                                      _alterando.contains(item.id);
                                  return Opacity(
                                    opacity: alterando ? .45 : 1,
                                    child: InkWell(
                                      onTap: alterando
                                          ? null
                                          : () => _alternarItem(
                                                controller,
                                                item,
                                                existente,
                                              ),
                                      child: ItemRecorrentePainelWidget(
                                        item: item,
                                        termoPesquisa: _pesquisa.text,
                                        corCategoria:
                                            categoria?.cor ?? corLista,
                                        tituloCategoria: categoria?.titulo ??
                                            'Sem categoria',
                                        selecionado: existente != null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _alternarItem(
    ListasController controller,
    ItemRecorrente recorrente,
    Item? existente,
  ) async {
    final id = recorrente.id;
    if (id == null) return;
    setState(() => _alterando.add(id));
    try {
      if (existente != null) {
        await controller.excluirItem(existente);
        _mensagem('Item removido da lista ativa.');
      } else {
        await controller.criarItem(
          Item(
            idLista: controller.idListaSelecionada!,
            idCategoria: recorrente.idCategoria,
            titulo: recorrente.titulo,
            tipoMedida: recorrente.tipoMedida,
            quantidade: recorrente.tipoMedida == TipoMedida.kg ? 1000 : 1,
          ),
        );
        _mensagem('Item incluído na lista ativa.');
      }
    } catch (_) {
      _mensagem('Não foi possível atualizar a lista.', erro: true);
    } finally {
      if (mounted) setState(() => _alterando.remove(id));
    }
  }

  Future<void> _selecionarCategoria(
    ListasController controller,
    Color corLista,
  ) async {
    final id = await SeletorCategoriaModal.exibir(
      context,
      categorias: controller.categorias,
      idSelecionado: _idCategoria,
      corDestaque: corLista,
      permitirTodas: true,
    );
    if (id == null || !mounted) return;
    setState(() => _idCategoria = id == 0 ? null : id);
  }

  String _tituloCategoria(ListasController controller) {
    if (_idCategoria == null) return 'Todas as categorias';
    for (final categoria in controller.categorias) {
      if (categoria.id == _idCategoria) return categoria.titulo;
    }
    return 'Todas as categorias';
  }

  void _mensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    _mensageiro.currentState?.showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  Color _corSobre(Color fundo) {
    return ThemeData.estimateBrightnessForColor(fundo) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}

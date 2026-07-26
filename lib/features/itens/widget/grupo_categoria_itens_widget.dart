import 'package:flutter/material.dart';

import '../../../core/utils/monetario_utils.dart';
import '../model/categoria_com_itens_model.dart';
import '../model/item_model.dart';

import 'item_da_lista_widget.dart';

class GrupoCategoriaItensWidget extends StatefulWidget {
  final CategoriaComItens grupo;
  final String chaveEstado;
  final bool inicialmenteExpandido;
  final ValueChanged<bool> aoAlterarExpansao;
  final void Function(Item item, bool marcado) aoAlterarMarcacao;
  final ValueChanged<Item> aoEditar;

  const GrupoCategoriaItensWidget({
    super.key,
    required this.grupo,
    required this.chaveEstado,
    required this.inicialmenteExpandido,
    required this.aoAlterarExpansao,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  State<GrupoCategoriaItensWidget> createState() =>
      _GrupoCategoriaItensWidgetState();
}

class _GrupoCategoriaItensWidgetState extends State<GrupoCategoriaItensWidget> {
  late bool _expandido;

  @override
  void initState() {
    super.initState();
    _expandido = widget.inicialmenteExpandido;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final grupo = widget.grupo;
    final corCategoria = grupo.categoria.cor;
    final corSobreCategoria = _corSobre(corCategoria);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      clipBehavior: Clip.antiAlias,
      color: tema.colorScheme.surface,
      child: ExpansionTile(
        key: PageStorageKey<String>(widget.chaveEstado),
        initiallyExpanded: widget.inicialmenteExpandido,
        onExpansionChanged: (expandido) {
          if (_expandido != expandido) {
            setState(() => _expandido = expandido);
          }
          widget.aoAlterarExpansao(expandido);
        },
        maintainState: true,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        minTileHeight: 56,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        backgroundColor: corCategoria.withAlpha(210),
        collapsedBackgroundColor: corCategoria.withAlpha(210),
        iconColor: corSobreCategoria,
        collapsedIconColor: corSobreCategoria,
        // leading: Container(
        //   width: 6,
        //   height: 14,
        //   decoration: BoxDecoration(
        //     color: corSobreCategoria.withAlpha(150),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        // ),
        title: Text(
          grupo.categoria.titulo,
          style: TextStyle(
            color: corSobreCategoria,
            fontWeight: FontWeight.w700,
            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '${grupo.quantidade} ${grupo.quantidade == 1 ? 'item' : 'itens'}',
              style: TextStyle(color: corSobreCategoria.withAlpha(205)),
            ),
            if (!_expandido) ...[
              const Spacer(),
              RichText(
                text: TextSpan(
                  text: '',
                  style: TextStyle(
                    color: corSobreCategoria,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '${MonetarioUtils.formatarIntToMoeda(grupo.subtotal)} / ',
                      style: TextStyle(color: corSobreCategoria.withAlpha(130)),
                    ),
                    TextSpan(
                      text: MonetarioUtils.formatarIntToMoeda(
                        grupo.totalMarcado,
                      ),
                      style: TextStyle(color: corSobreCategoria),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        children: [
          ColoredBox(
            color: tema.colorScheme.surface,
            child: _ItensDaCategoria(
              itens: grupo.itens,
              chaveRolagem: 'rolagem-${widget.chaveEstado}',
              corCategoria: corCategoria,
              aoAlterarMarcacao: widget.aoAlterarMarcacao,
              aoEditar: widget.aoEditar,
            ),
          ),
          ColoredBox(
            color: corCategoria.withAlpha(10),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 40,
                left: 15,
                bottom: 5,
                top: 5,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: TextStyle(color: corSobreCategoria)),
                  RichText(
                    text: TextSpan(
                      text: '',
                      style: TextStyle(
                        color: corSobreCategoria,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${MonetarioUtils.formatarIntToMoeda(grupo.subtotal)} / ',
                          style: TextStyle(
                            color: corSobreCategoria.withAlpha(130),
                          ),
                        ),
                        TextSpan(
                          text: MonetarioUtils.formatarIntToMoeda(
                            grupo.totalMarcado,
                          ),
                          style: TextStyle(color: corSobreCategoria),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _corSobre(Color fundo) {
    return ThemeData.estimateBrightnessForColor(fundo) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }
}

class _ItensDaCategoria extends StatefulWidget {
  static const int limiteSemRolagem = 5;
  static const double alturaLinhaCompacta = 54;

  final List<Item> itens;
  final String chaveRolagem;
  final Color corCategoria;
  final void Function(Item item, bool marcado) aoAlterarMarcacao;
  final ValueChanged<Item> aoEditar;

  const _ItensDaCategoria({
    required this.itens,
    required this.chaveRolagem,
    required this.corCategoria,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  State<_ItensDaCategoria> createState() => _ItensDaCategoriaState();
}

class _ItensDaCategoriaState extends State<_ItensDaCategoria> {
  ScrollController? _controleRolagem;

  @override
  void initState() {
    super.initState();
    _atualizarControleRolagem();
  }

  @override
  void didUpdateWidget(covariant _ItensDaCategoria oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.itens.length > _ItensDaCategoria.limiteSemRolagem) !=
        (widget.itens.length > _ItensDaCategoria.limiteSemRolagem)) {
      _atualizarControleRolagem();
    }
  }

  @override
  void dispose() {
    _controleRolagem?.dispose();
    super.dispose();
  }

  void _atualizarControleRolagem() {
    _controleRolagem?.dispose();
    _controleRolagem = widget.itens.length > _ItensDaCategoria.limiteSemRolagem
        ? ScrollController()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.itens;
    if (itens.length <= _ItensDaCategoria.limiteSemRolagem) {
      return Column(
        children: [
          const Divider(height: 1, thickness: .1),
          for (var indice = 0; indice < itens.length; indice++) ...[
            _ItemDaCategoria(
              key: ValueKey(itens[indice].id ?? itens[indice]),
              item: itens[indice],
              corCategoria: widget.corCategoria,
              aoAlterarMarcacao: widget.aoAlterarMarcacao,
              aoEditar: widget.aoEditar,
            ),
            if (indice < itens.length - 1)
              const Divider(height: 1, thickness: .1),
          ],
        ],
      );
    }
    return Column(
      children: [
        const Divider(height: 1, thickness: .1),
        SizedBox(
          key: const ValueKey('rolagem-interna-categoria'),
          height: _ItensDaCategoria.alturaLinhaCompacta *
              _ItensDaCategoria.limiteSemRolagem,
          child: Scrollbar(
            key: const ValueKey('indicador-rolagem-categoria'),
            controller: _controleRolagem,
            thumbVisibility: true,
            child: ListView.separated(
              key: PageStorageKey<String>(widget.chaveRolagem),
              controller: _controleRolagem,
              primary: false,
              padding: const EdgeInsets.all(0),
              physics: const ClampingScrollPhysics(),
              itemCount: itens.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 2, thickness: .1),
              itemBuilder: (_, indice) => _ItemDaCategoria(
                key: ValueKey(itens[indice].id ?? itens[indice]),
                item: itens[indice],
                corCategoria: widget.corCategoria,
                aoAlterarMarcacao: widget.aoAlterarMarcacao,
                aoEditar: widget.aoEditar,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemDaCategoria extends StatelessWidget {
  final Item item;
  final Color corCategoria;
  final void Function(Item item, bool marcado) aoAlterarMarcacao;
  final ValueChanged<Item> aoEditar;

  const _ItemDaCategoria({
    super.key,
    required this.item,
    required this.corCategoria,
    required this.aoAlterarMarcacao,
    required this.aoEditar,
  });

  @override
  Widget build(BuildContext context) {
    return ItemDaListaWidget(
      item: item,
      corCategoria: corCategoria,
      aoAlterarMarcacao: (valor) => aoAlterarMarcacao(item, valor),
      aoEditar: () => aoEditar(item),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/enums/prioridade.dart';
import '../../categoria/extensions/categorias_extension.dart';
import '../../categoria/model/categoria_model.dart';
import '../../categoria/widget/seletor_categoria.dart';
import '../extensions/opcoes_itens_apresentacao_extension.dart';
import '../model/filtro_itens.dart';
import 'estilo_selecao_itens.dart';

class FiltroItensSheet extends StatefulWidget {
  final FiltroItens filtroInicial;
  final List<Categoria> categorias;
  final Color corLista;

  const FiltroItensSheet({
    super.key,
    required this.filtroInicial,
    required this.categorias,
    required this.corLista,
  });

  @override
  State<FiltroItensSheet> createState() => _FiltroItensSheetState();
}

class _FiltroItensSheetState extends State<FiltroItensSheet> {
  late SituacaoItem situacao = widget.filtroInicial.situacao;
  late int? idCategoria = widget.filtroInicial.idCategoria;
  late Prioridade? prioridade = widget.filtroInicial.prioridade;
  late bool? possuiPreco = widget.filtroInicial.possuiPreco;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            'Mais filtros',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text('Situação', style: Theme.of(context).textTheme.labelLarge),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<SituacaoItem>(
              segments: SituacaoItem.values
                  .map(
                    (valor) => ButtonSegment<SituacaoItem>(
                      value: valor,
                      label: Text(valor.rotulo),
                    ),
                  )
                  .toList(growable: false),
              selected: {situacao},
              showSelectedIcon: false,
              style: EstiloSelecaoItens.segmentado(widget.corLista),
              onSelectionChanged: (valor) {
                setState(() => situacao = valor.first);
              },
            ),
          ),
          OutlinedButton.icon(
            key: const ValueKey('selecionar-categoria-filtro-itens'),
            onPressed: _selecionarCategoria,
            icon: const Icon(PhosphorIcons.tag),
            label: Text(widget.categorias.tituloPorId(idCategoria)),
          ),
          Text('Prioridade', style: Theme.of(context).textTheme.labelLarge),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<Prioridade?>(
              segments: [
                const ButtonSegment<Prioridade?>(
                  value: null,
                  label: Text('Todas'),
                ),
                ...Prioridade.values.map(
                  (valor) => ButtonSegment<Prioridade?>(
                    value: valor,
                    label: Text(valor.rotulo),
                  ),
                ),
              ],
              selected: {prioridade},
              showSelectedIcon: false,
              style: EstiloSelecaoItens.segmentado(widget.corLista),
              onSelectionChanged: (valor) {
                setState(() => prioridade = valor.first);
              },
            ),
          ),
          Text('Preço', style: Theme.of(context).textTheme.labelLarge),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool?>(
              segments: const [
                ButtonSegment<bool?>(value: null, label: Text('Todos')),
                ButtonSegment<bool?>(value: true, label: Text('Com preço')),
                ButtonSegment<bool?>(value: false, label: Text('Sem preço')),
              ],
              selected: {possuiPreco},
              showSelectedIcon: false,
              style: EstiloSelecaoItens.segmentado(widget.corLista),
              onSelectionChanged: (valor) {
                setState(() => possuiPreco = valor.first);
              },
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  const FiltroItens(),
                ),
                child: const Text('Limpar'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  FiltroItens(
                    situacao: situacao,
                    idCategoria: idCategoria,
                    prioridade: prioridade,
                    possuiPreco: possuiPreco,
                  ),
                ),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarCategoria() async {
    final resultado = await SeletorCategoria.exibir(
      context,
      categorias: widget.categorias,
      idSelecionado: idCategoria,
      corDestaque: widget.corLista,
      permitirTodas: true,
    );
    if (resultado == null || !mounted) return;
    setState(() => idCategoria = resultado.idCategoria);
  }
}

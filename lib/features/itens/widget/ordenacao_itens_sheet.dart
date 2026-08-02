import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
import 'estilo_selecao_itens.dart';

class OrdenacaoItensSheet extends StatefulWidget {
  final OrdenarPor ordenarPor;
  final Ordem ordem;
  final Color corLista;

  const OrdenacaoItensSheet({
    super.key,
    required this.ordenarPor,
    required this.ordem,
    required this.corLista,
  });

  @override
  State<OrdenacaoItensSheet> createState() => _OrdenacaoItensSheetState();
}

class _OrdenacaoItensSheetState extends State<OrdenacaoItensSheet> {
  late OrdenarPor ordenarPor = widget.ordenarPor == OrdenarPor.data
      ? OrdenarPor.nome
      : widget.ordenarPor;
  late Ordem ordem = widget.ordem;

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
            'Ordenar itens',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text('Ordenar por', style: Theme.of(context).textTheme.labelLarge),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<OrdenarPor>(
              segments: const [
                ButtonSegment(value: OrdenarPor.nome, label: Text('Nome')),
                ButtonSegment(value: OrdenarPor.preco, label: Text('Preço')),
                ButtonSegment(
                  value: OrdenarPor.prioridade,
                  label: Text('Prioridade'),
                ),
              ],
              selected: {ordenarPor},
              showSelectedIcon: false,
              style: EstiloSelecaoItens.segmentado(widget.corLista),
              onSelectionChanged: (valor) {
                setState(() => ordenarPor = valor.first);
              },
            ),
          ),
          SegmentedButton<Ordem>(
            segments: const [
              ButtonSegment(
                value: Ordem.ascendente,
                icon: Icon(PhosphorIcons.sortAscending),
                label: Text('Crescente'),
              ),
              ButtonSegment(
                value: Ordem.descendente,
                icon: Icon(PhosphorIcons.sortDescending),
                label: Text('Decrescente'),
              ),
            ],
            selected: {ordem},
            showSelectedIcon: false,
            style: EstiloSelecaoItens.segmentado(widget.corLista),
            onSelectionChanged: (valor) {
              setState(() => ordem = valor.first);
            },
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, (ordenarPor, ordem)),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

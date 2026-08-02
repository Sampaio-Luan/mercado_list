import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
import '../../../core/extensions/cor_contraste_extension.dart';
import '../../categoria/model/categoria_model.dart';
import '../extensions/opcoes_itens_apresentacao_extension.dart';
import '../model/filtro_itens.dart';

class BarraFiltrosOrdenacaoItens extends StatelessWidget {
  final bool habilitada;
  final FiltroItens filtro;
  final List<Categoria> categorias;
  final OrdenarPor ordenarPor;
  final Ordem ordem;
  final Color corLista;
  final ValueChanged<SituacaoItem> aoAlterarSituacao;
  final VoidCallback aoAbrirFiltros;
  final VoidCallback aoLimparFiltros;
  final VoidCallback aoAbrirOrdenacao;

  const BarraFiltrosOrdenacaoItens({
    super.key,
    required this.habilitada,
    required this.filtro,
    required this.categorias,
    required this.ordenarPor,
    required this.ordem,
    required this.corLista,
    required this.aoAlterarSituacao,
    required this.aoAbrirFiltros,
    required this.aoLimparFiltros,
    required this.aoAbrirOrdenacao,
  });

  @override
  Widget build(BuildContext context) {
    final corComContraste = corLista.paraPrimeiroPlano(Theme.of(context));
    return Material(
      key: const ValueKey('barra-filtros-ordenacao-itens'),
      color: Theme.of(context).colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: .5,
            ),
          ),
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              _BotaoMaisFiltros(
                habilitado: habilitada,
                ativo: filtro.possuiFiltrosAdicionais,
                cor: corComContraste,
                aoPressionar: aoAbrirFiltros,
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('rolagem-chips-filtros-itens'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: filtro.possuiFiltrosAdicionais
                      ? _ResumoFiltrosChip(
                          habilitado: habilitada,
                          filtro: filtro,
                          categorias: categorias,
                          cor: corComContraste,
                          aoPressionar: aoAbrirFiltros,
                          aoLimpar: aoLimparFiltros,
                        )
                      : _ChipsSituacaoItens(
                          habilitados: habilitada,
                          situacao: filtro.situacao,
                          cor: corComContraste,
                          aoAlterar: aoAlterarSituacao,
                        ),
                ),
              ),
              VerticalDivider(
                key: const ValueKey('divisor-filtro-ordenacao-itens'),
                width: 1,
                thickness: 1,
                indent: 8,
                endIndent: 8,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _OrdenacaoChip(
                  habilitado: habilitada,
                  ordenarPor: ordenarPor,
                  ordem: ordem,
                  cor: corComContraste,
                  aoPressionar: aoAbrirOrdenacao,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoMaisFiltros extends StatelessWidget {
  final bool habilitado;
  final bool ativo;
  final Color cor;
  final VoidCallback aoPressionar;

  const _BotaoMaisFiltros({
    required this.habilitado,
    required this.ativo,
    required this.cor,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('mais-filtros-itens'),
      tooltip: 'Mais filtros',
      onPressed: habilitado ? aoPressionar : null,
      style: IconButton.styleFrom(
        foregroundColor: cor,
        backgroundColor: ativo ? cor.withAlpha(28) : null,
        side: ativo ? BorderSide(color: cor.withAlpha(180)) : null,
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(PhosphorIcons.funnel, size: 20),
    );
  }
}

class _ChipsSituacaoItens extends StatelessWidget {
  final bool habilitados;
  final SituacaoItem situacao;
  final Color cor;
  final ValueChanged<SituacaoItem> aoAlterar;

  const _ChipsSituacaoItens({
    required this.habilitados,
    required this.situacao,
    required this.cor,
    required this.aoAlterar,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 3,
      children: SituacaoItem.values
          .map(
            (valor) => ChoiceChip(
              key: ValueKey('situacao-itens-${valor.name}'),
              label: Text(valor.rotulo),
              selected: situacao == valor,
              showCheckmark: false,
              selectedColor: cor.withAlpha(28),
              side: WidgetStateBorderSide.resolveWith(
                (estados) => BorderSide(
                  color: estados.contains(WidgetState.selected)
                      ? cor.withAlpha(210)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              labelStyle: WidgetStateTextStyle.resolveWith(
                (estados) => TextStyle(
                  color: estados.contains(WidgetState.selected)
                      ? cor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: estados.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: habilitados ? (_) => aoAlterar(valor) : null,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ResumoFiltrosChip extends StatelessWidget {
  final bool habilitado;
  final FiltroItens filtro;
  final List<Categoria> categorias;
  final Color cor;
  final VoidCallback aoPressionar;
  final VoidCallback aoLimpar;

  const _ResumoFiltrosChip({
    required this.habilitado,
    required this.filtro,
    required this.categorias,
    required this.cor,
    required this.aoPressionar,
    required this.aoLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final resumo = _resumo();
    return InputChip(
      key: const ValueKey('resumo-filtros-itens'),
      tooltip: 'Editar filtros: $resumo',
      label: Text(resumo),
      deleteIcon: Icon(PhosphorIcons.xCircle, size: 16, color: cor),
      deleteButtonTooltipMessage: 'Limpar filtros',
      backgroundColor: cor.withAlpha(28),
      side: BorderSide(color: cor.withAlpha(210)),
      labelStyle: TextStyle(color: cor, fontWeight: FontWeight.w700),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: habilitado ? aoPressionar : null,
      onDeleted: habilitado ? aoLimpar : null,
    );
  }

  String _resumo() {
    final partes = <String>[filtro.situacao.rotulo];
    if (filtro.possuiPreco case final possuiPreco?) {
      partes.add(possuiPreco ? 'Com preço' : 'Sem preço');
    }
    if (filtro.prioridade case final prioridade?) {
      partes.add('P: ${prioridade.rotulo}');
    }
    if (filtro.idCategoria case final idCategoria?) {
      partes.add('Cat: ${_tituloCategoria(idCategoria)}');
    }
    return partes.join(' / ');
  }

  String _tituloCategoria(int idCategoria) {
    for (final categoria in categorias) {
      if (categoria.id == idCategoria) return categoria.titulo;
    }
    return 'Sem categoria';
  }
}

class _OrdenacaoChip extends StatelessWidget {
  final bool habilitado;
  final OrdenarPor ordenarPor;
  final Ordem ordem;
  final Color cor;
  final VoidCallback aoPressionar;

  const _OrdenacaoChip({
    required this.habilitado,
    required this.ordenarPor,
    required this.ordem,
    required this.cor,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      key: const ValueKey('ordenar-itens'),
      tooltip: 'Ordenar itens: ${ordenarPor.rotulo}, '
          '${ordem.rotulo.toLowerCase()}',
      avatar: Icon(
        ordem == Ordem.ascendente
            ? PhosphorIcons.sortAscending
            : PhosphorIcons.sortDescending,
        size: 17,
        color: cor,
      ),
      label: Text(ordenarPor.rotulo),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: cor),
      labelStyle: TextStyle(color: cor, fontWeight: FontWeight.w600),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.only(left: 2, right: 5),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: habilitado ? aoPressionar : null,
    );
  }
}

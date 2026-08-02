import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/enums/ordem.dart';
import '../../../core/constants/enums/ordenar_por.dart';
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
  final VoidCallback aoAbrirFiltros;
  final VoidCallback aoLimparFiltros;
  final VoidCallback aoAbrirOrdenacao;
  final VoidCallback aoLimparOrdenacao;

  const BarraFiltrosOrdenacaoItens({
    super.key,
    required this.habilitada,
    required this.filtro,
    required this.categorias,
    required this.ordenarPor,
    required this.ordem,
    required this.corLista,
    required this.aoAbrirFiltros,
    required this.aoLimparFiltros,
    required this.aoAbrirOrdenacao,
    required this.aoLimparOrdenacao,
  });

  @override
  Widget build(BuildContext context) {
    final ordenacaoAtiva =
        ordenarPor != OrdenarPor.nome || ordem != Ordem.ascendente;

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
                ativo: filtro.ativo,
                corLista: corLista,
                aoPressionar: aoAbrirFiltros,
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('rolagem-chip-filtro-itens'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _ResumoFiltrosChip(
                    habilitado: habilitada,
                    filtro: filtro,
                    categorias: categorias,
                    corLista: corLista,
                    aoPressionar: aoAbrirFiltros,
                    aoLimpar: aoLimparFiltros,
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
              Expanded(
                child: SingleChildScrollView(
                  key: const ValueKey('rolagem-chip-ordenacao-itens'),
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _ResumoOrdenacaoChip(
                    habilitado: habilitada,
                    ordenarPor: ordenarPor,
                    ordem: ordem,
                    ativa: ordenacaoAtiva,
                    corLista: corLista,
                    aoPressionar: aoAbrirOrdenacao,
                    aoLimpar: aoLimparOrdenacao,
                  ),
                ),
              ),
              _BotaoOrdenacao(
                habilitado: habilitada,
                ativo: ordenacaoAtiva,
                ordenarPor: ordenarPor,
                ordem: ordem,
                corLista: corLista,
                aoPressionar: aoAbrirOrdenacao,
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
  final Color corLista;
  final VoidCallback aoPressionar;

  const _BotaoMaisFiltros({
    required this.habilitado,
    required this.ativo,
    required this.corLista,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('mais-filtros-itens'),
      tooltip: 'Filtrar itens',
      onPressed: habilitado ? aoPressionar : null,
      style: IconButton.styleFrom(
        foregroundColor: corLista,
        backgroundColor: ativo ? corLista.withAlpha(28) : null,
        side: ativo ? BorderSide(color: corLista.withAlpha(180)) : null,
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(PhosphorIcons.funnel, size: 20),
    );
  }
}

class _ResumoFiltrosChip extends StatelessWidget {
  final bool habilitado;
  final FiltroItens filtro;
  final List<Categoria> categorias;
  final Color corLista;
  final VoidCallback aoPressionar;
  final VoidCallback aoLimpar;

  const _ResumoFiltrosChip({
    required this.habilitado,
    required this.filtro,
    required this.categorias,
    required this.corLista,
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
      deleteIcon: Icon(PhosphorIcons.xCircle, size: 16, color: corLista),
      deleteButtonTooltipMessage: 'Limpar filtros',
      backgroundColor: corLista.withAlpha(28),
      side: BorderSide(color: corLista.withAlpha(210)),
      labelStyle: TextStyle(color: corLista, fontWeight: FontWeight.w700),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: habilitado ? aoPressionar : null,
      onDeleted: habilitado && filtro.ativo ? aoLimpar : null,
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

class _ResumoOrdenacaoChip extends StatelessWidget {
  final bool habilitado;
  final OrdenarPor ordenarPor;
  final Ordem ordem;
  final bool ativa;
  final Color corLista;
  final VoidCallback aoPressionar;
  final VoidCallback aoLimpar;

  const _ResumoOrdenacaoChip({
    required this.habilitado,
    required this.ordenarPor,
    required this.ordem,
    required this.ativa,
    required this.corLista,
    required this.aoPressionar,
    required this.aoLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final resumo = '${ordenarPor.rotulo} / ${ordem.rotulo}';
    return InputChip(
      key: const ValueKey('resumo-ordenacao-itens'),
      tooltip: 'Editar ordenação: $resumo',
      label: Text(resumo),
      deleteIcon: Icon(PhosphorIcons.xCircle, size: 16, color: corLista),
      deleteButtonTooltipMessage: 'Restaurar ordenação padrão',
      backgroundColor: corLista.withAlpha(28),
      side: BorderSide(color: corLista.withAlpha(210)),
      labelStyle: TextStyle(color: corLista, fontWeight: FontWeight.w700),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: habilitado ? aoPressionar : null,
      onDeleted: habilitado && ativa ? aoLimpar : null,
    );
  }
}

class _BotaoOrdenacao extends StatelessWidget {
  final bool habilitado;
  final bool ativo;
  final OrdenarPor ordenarPor;
  final Ordem ordem;
  final Color corLista;
  final VoidCallback aoPressionar;

  const _BotaoOrdenacao({
    required this.habilitado,
    required this.ativo,
    required this.ordenarPor,
    required this.ordem,
    required this.corLista,
    required this.aoPressionar,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('ordenar-itens'),
      tooltip: 'Ordenar itens: ${ordenarPor.rotulo}, '
          '${ordem.rotulo.toLowerCase()}',
      onPressed: habilitado ? aoPressionar : null,
      style: IconButton.styleFrom(
        foregroundColor: corLista,
        backgroundColor: ativo ? corLista.withAlpha(28) : null,
        side: ativo ? BorderSide(color: corLista.withAlpha(180)) : null,
        shape: const StadiumBorder(),
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(
        ordem == Ordem.ascendente
            ? PhosphorIcons.sortAscending
            : PhosphorIcons.sortDescending,
        size: 20,
      ),
    );
  }
}

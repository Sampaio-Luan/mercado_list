import 'package:flutter/material.dart';

import '../../../core/extensions/cor_contraste_extension.dart';
import '../controller/compartilhamento_controller.dart';
import '../model/compartilhamento_model.dart';
import '../service/compartilhamento_service.dart';

class CompartilhamentoSheet extends StatefulWidget {
  const CompartilhamentoSheet({
    super.key,
    required this.conteudo,
    required this.corDestaque,
    required this.service,
  });

  final ConteudoCompartilhamento conteudo;
  final Color corDestaque;
  final CompartilhamentoService service;

  static Future<void> exibir(
    BuildContext context, {
    required ConteudoCompartilhamento conteudo,
    required Color corDestaque,
    required CompartilhamentoService service,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => CompartilhamentoSheet(
        conteudo: conteudo,
        corDestaque: corDestaque,
        service: service,
      ),
    );
  }

  @override
  State<CompartilhamentoSheet> createState() => _CompartilhamentoSheetState();
}

class _CompartilhamentoSheetState extends State<CompartilhamentoSheet> {
  late final CompartilhamentoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompartilhamentoController(widget.conteudo, widget.service);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final tema = Theme.of(context);
        final corAcao = widget.corDestaque.paraPrimeiroPlano(tema);
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .9,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.ios_share_outlined, color: corAcao),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Compartilhar ${widget.conteudo.titulo}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.conteudo.escoposDisponiveis.length > 1) ...[
                          const _TituloSecao('Quais itens?'),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: widget.conteudo.escoposDisponiveis
                                .map(
                                  (escopo) => ChoiceChip(
                                    label: Text(
                                      '${escopo.rotulo} (${widget.conteudo.quantidadeNoEscopo(escopo)})',
                                    ),
                                    selected: _controller.escopo == escopo,
                                    onSelected: widget.conteudo
                                                .quantidadeNoEscopo(
                                              escopo,
                                            ) ==
                                            0
                                        ? null
                                        : (_) => _controller.selecionarEscopo(
                                              escopo,
                                            ),
                                    selectedColor:
                                        widget.corDestaque.withValues(
                                      alpha: .16,
                                    ),
                                    side: _controller.escopo == escopo
                                        ? BorderSide(color: corAcao)
                                        : null,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 18),
                        ],
                        const _TituloSecao('Informações incluídas'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: CampoCompartilhamento.values
                              .where(
                            widget.conteudo.camposDisponiveis.contains,
                          )
                              .map((campo) {
                            final obrigatorio =
                                campo == CampoCompartilhamento.titulo;
                            return FilterChip(
                              label: Text(campo.rotulo),
                              selected: _controller.camposSelecionados
                                  .contains(campo),
                              onSelected: obrigatorio
                                  ? (_) {}
                                  : (_) => _controller.alternarCampo(campo),
                              avatar: obrigatorio
                                  ? const Icon(Icons.lock_outline, size: 16)
                                  : null,
                              selectedColor: widget.corDestaque.withValues(
                                alpha: .16,
                              ),
                              checkmarkColor: corAcao,
                            );
                          }).toList(growable: false),
                        ),
                        const SizedBox(height: 18),
                        const _TituloSecao('Formato'),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: FormatoCompartilhamento.values
                              .map(
                                (formato) => ChoiceChip(
                                  avatar: Icon(
                                    _iconeFormato(formato),
                                    size: 18,
                                    color: _controller.formato == formato
                                        ? corAcao
                                        : tema.colorScheme.onSurfaceVariant,
                                  ),
                                  label: Text(formato.rotulo),
                                  selected: _controller.formato == formato,
                                  onSelected: (_) =>
                                      _controller.selecionarFormato(formato),
                                  selectedColor: widget.corDestaque.withValues(
                                    alpha: .16,
                                  ),
                                  side: _controller.formato == formato
                                      ? BorderSide(color: corAcao)
                                      : null,
                                ),
                              )
                              .toList(growable: false),
                        ),
                        if (_controller.mensagemErro != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _controller.mensagemErro!,
                            style: TextStyle(color: tema.colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('compartilhar-confirmar'),
                  onPressed: _controller.compartilhando
                      ? null
                      : () => _compartilhar(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.corDestaque,
                    foregroundColor: widget.corDestaque.corSobre,
                  ),
                  icon: _controller.compartilhando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.ios_share_outlined),
                  label: Text(
                    _controller.compartilhando
                        ? 'Preparando...'
                        : 'Compartilhar',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _compartilhar(BuildContext context) async {
    final caixa = context.findRenderObject() as RenderBox?;
    final origem =
        caixa == null ? null : caixa.localToGlobal(Offset.zero) & caixa.size;
    final resultado = await _controller.compartilhar(origem: origem);
    if (!context.mounted || resultado == null) return;
    Navigator.of(context).pop();
  }

  IconData _iconeFormato(FormatoCompartilhamento formato) => switch (formato) {
        FormatoCompartilhamento.imagem => Icons.image_outlined,
        FormatoCompartilhamento.pdf => Icons.picture_as_pdf_outlined,
        FormatoCompartilhamento.csv => Icons.table_rows_outlined,
        FormatoCompartilhamento.excel => Icons.grid_on_outlined,
        FormatoCompartilhamento.json => Icons.data_object,
      };
}

class _TituloSecao extends StatelessWidget {
  const _TituloSecao(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

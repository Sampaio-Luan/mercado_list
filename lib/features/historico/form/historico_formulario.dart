import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/utils/data_utils.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../../../shared/widgets/painel_pesquisa/similaridade_texto.dart';
import '../../../shared/widgets/painel_pesquisa/texto_destacado_pesquisa.dart';
import '../../../shared/widgets/seletor_de_cor.dart';
import '../model/historico_com_itens_model.dart';
import '../model/historico_model.dart';

class HistoricoFormulario extends StatefulWidget {
  const HistoricoFormulario({
    super.key,
    required this.historico,
    required this.tituloFormulario,
    this.sugestoesLojas = const [],
    this.quantidadeItens,
    this.quantidadeItensIgnorados = 0,
  });

  final Historico historico;
  final String tituloFormulario;
  final List<String> sugestoesLojas;
  final int? quantidadeItens;
  final int quantidadeItensIgnorados;

  static Future<Historico?> criar(
    BuildContext context, {
    required Historico historico,
    required int quantidadeItens,
    required int quantidadeItensIgnorados,
    List<String> sugestoesLojas = const [],
  }) {
    return _exibir(
      context,
      HistoricoFormulario(
        historico: historico,
        tituloFormulario: 'Salvar compra',
        sugestoesLojas: sugestoesLojas,
        quantidadeItens: quantidadeItens,
        quantidadeItensIgnorados: quantidadeItensIgnorados,
      ),
    );
  }

  static Future<Historico?> editar(
    BuildContext context,
    HistoricoComItens compra, {
    List<String> sugestoesLojas = const [],
  }) {
    return _exibir(
      context,
      HistoricoFormulario(
        historico: compra.historico,
        tituloFormulario: 'Editar compra',
        sugestoesLojas: sugestoesLojas,
      ),
    );
  }

  static Future<Historico?> _exibir(
    BuildContext context,
    HistoricoFormulario formulario,
  ) {
    return showModalBottomSheet<Historico>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: formulario,
      ),
    );
  }

  @override
  State<HistoricoFormulario> createState() => _HistoricoFormularioState();
}

class _HistoricoFormularioState extends State<HistoricoFormulario> {
  final _chaveFormulario = GlobalKey<FormState>();
  late Historico _historico = widget.historico.copia();

  @override
  Widget build(BuildContext context) {
    final cor = _historico.cor;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Form(
        key: _chaveFormulario,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.tituloFormulario,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (widget.quantidadeItens case final quantidade?) ...[
              const SizedBox(height: 12),
              _ResumoItensHistorico(
                quantidade: quantidade,
                ignorados: widget.quantidadeItensIgnorados,
                cor: cor,
              ),
            ],
            const SizedBox(height: 16),
            CampoDeTexto(
              rotulo: 'Título',
              valor: _historico.titulo,
              validadores: [
                () => _historico.titulo.trim().isEmpty
                    ? 'O título é obrigatório.'
                    : null,
              ],
              onChanged: (valor) => _historico.titulo = valor,
            ),
            const SizedBox(height: 12),
            CampoDeTexto(
              rotulo: 'Descrição (opcional)',
              valor: _historico.descricao ?? '',
              linhas: 3,
              validadores: const [],
              onChanged: (valor) => _historico = _historico.copia(
                descricao: valor,
                limparDescricao: valor.trim().isEmpty,
              ),
            ),
            const SizedBox(height: 12),
            _CampoLoja(
              valor: _historico.loja ?? '',
              sugestoes: widget.sugestoesLojas,
              onChanged: (valor) => _historico = _historico.copia(
                loja: valor,
                limparLoja: valor.trim().isEmpty,
              ),
            ),
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(PhosphorIcons.calendarBlank, color: cor),
              title: const Text('Data da compra'),
              subtitle: Text(DataUtils.formatarData(_historico.dataCompra)),
              trailing: const Icon(PhosphorIcons.calendarCheck),
              onTap: _selecionarData,
            ),
            RealField(
              rotulo: 'Orçamento (opcional)',
              valor: _historico.orcamento,
              validadores: const [],
              onChanged: (valor) {
                final digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
                _historico = _historico.copia(
                  orcamento: digitos.isEmpty ? null : int.parse(digitos),
                  limparOrcamento: digitos.isEmpty,
                );
              },
            ),
            const SizedBox(height: 12),
            Text('Cor', style: Theme.of(context).textTheme.labelLarge),
            SeletorDeCor(
              corSelecionada: Cor.obterPorColor(color: cor),
              onCorSelecionada: (valor) {
                setState(() {
                  _historico = _historico.copia(
                    cor: Cor.obterCor(cor: valor),
                  );
                });
              },
            ),
            const SizedBox(height: 14),
            LinhaBotoesConfirmacao(
              cor: cor,
              onConfirmar: _confirmar,
              onCancelar: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData() async {
    final atual = _historico.dataCompra.toLocal();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selecionada == null) return;
    setState(() {
      _historico = _historico.copia(
        dataCompra: DateTime(
          selecionada.year,
          selecionada.month,
          selecionada.day,
          atual.hour,
          atual.minute,
        ),
      );
    });
  }

  void _confirmar() {
    if (!_chaveFormulario.currentState!.validate()) return;
    Navigator.pop(context, _historico);
  }
}

class _CampoLoja extends StatefulWidget {
  const _CampoLoja({
    required this.valor,
    required this.sugestoes,
    required this.onChanged,
  });

  final String valor;
  final List<String> sugestoes;
  final ValueChanged<String> onChanged;

  @override
  State<_CampoLoja> createState() => _CampoLojaState();
}

class _CampoLojaState extends State<_CampoLoja> {
  String _termo = '';

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: widget.valor),
      displayStringForOption: (opcao) => opcao,
      optionsBuilder: (valorDigitado) {
        final termo = valorDigitado.text.trim();
        final aindaNaoDigitou = _termo.isEmpty && termo == widget.valor.trim();
        if (termo.isEmpty || aindaNaoDigitou) {
          return const Iterable<String>.empty();
        }
        final ordenadas = widget.sugestoes
            .map(
              (loja) => (
                loja: loja,
                relevancia: SimilaridadeTexto.calcularPontuacaoRelevancia(
                  textoItem: loja,
                  textoPesquisa: termo,
                ),
              ),
            )
            .where((sugestao) => sugestao.relevancia > 0)
            .toList()
          ..sort((a, b) => b.relevancia.compareTo(a.relevancia));
        return ordenadas.take(3).map((sugestao) => sugestao.loja);
      },
      onSelected: widget.onChanged,
      optionsViewBuilder: (context, onSelected, opcoes) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 32,
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: opcoes.length,
              itemBuilder: (_, indice) {
                final loja = opcoes.elementAt(indice);
                return InkWell(
                  onTap: () => onSelected(loja),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        const Icon(PhosphorIcons.storefront, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextoDestacadoPesquisa(
                            texto: loja,
                            textoPesquisa: _termo,
                            maximoLinhas: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      fieldViewBuilder: (_, controller, foco, aoEnviar) => TextFormField(
        controller: controller,
        focusNode: foco,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Loja (opcional)',
          prefixIcon: Icon(PhosphorIcons.storefront),
        ),
        onChanged: (valor) {
          setState(() => _termo = valor);
          widget.onChanged(valor);
        },
        onFieldSubmitted: (_) => aoEnviar(),
      ),
    );
  }
}

class _ResumoItensHistorico extends StatelessWidget {
  const _ResumoItensHistorico({
    required this.quantidade,
    required this.ignorados,
    required this.cor,
  });

  final int quantidade;
  final int ignorados;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(PhosphorIcons.info, color: cor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$quantidade ${quantidade == 1 ? 'item marcado com preço será salvo' : 'itens marcados com preço serão salvos'}.'
                '${ignorados > 0 ? ' $ignorados ${ignorados == 1 ? 'item marcado sem preço será ignorado' : 'itens marcados sem preço serão ignorados'}.' : ''}',
                style: tema.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

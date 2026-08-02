import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/utils/data_utils.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../../../shared/widgets/seletor_de_cor.dart';
import '../controller/historico_controller.dart';
import '../model/historico_com_itens_model.dart';
import '../model/historico_model.dart';

class HistoricoFormulario extends StatefulWidget {
  const HistoricoFormulario({super.key, required this.compra});

  final HistoricoComItens compra;

  static Future<void> exibir(
    BuildContext context,
    HistoricoComItens compra,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: HistoricoFormulario(compra: compra),
      ),
    );
  }

  @override
  State<HistoricoFormulario> createState() => _HistoricoFormularioState();
}

class _HistoricoFormularioState extends State<HistoricoFormulario> {
  final _chaveFormulario = GlobalKey<FormState>();
  late Historico _historico = widget.compra.historico.copia();
  bool _salvando = false;

  @override
  Widget build(BuildContext context) {
    final cor = _historico.cor;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Form(
        key: _chaveFormulario,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Editar compra',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_month_outlined, color: cor),
              title: const Text('Data da compra'),
              subtitle: Text(DataUtils.formatarData(_historico.dataCompra)),
              trailing: const Icon(Icons.edit_calendar_outlined),
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
              onConfirmar: _salvando ? () {} : _salvar,
              onCancelar: () {
                if (!_salvando) Navigator.pop(context);
              },
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

  Future<void> _salvar() async {
    if (_salvando || !_chaveFormulario.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      await context.read<HistoricoController>().editar(
            widget.compra,
            _historico,
          );
      if (!mounted) return;
      context.mostrarSucesso('Compra atualizada com sucesso.');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) context.mostrarErro('Não foi possível editar a compra.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

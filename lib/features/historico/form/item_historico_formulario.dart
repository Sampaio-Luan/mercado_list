import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/campos_formulario/peso_field.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../model/item_historico_model.dart';

class ItemHistoricoFormulario extends StatefulWidget {
  const ItemHistoricoFormulario({
    super.key,
    required this.item,
    required this.cor,
  });

  final ItemHistorico item;
  final Color cor;

  static Future<ItemHistorico?> exibir(
    BuildContext context, {
    required ItemHistorico item,
    required Color cor,
  }) {
    return showModalBottomSheet<ItemHistorico>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ItemHistoricoFormulario(item: item, cor: cor),
      ),
    );
  }

  @override
  State<ItemHistoricoFormulario> createState() =>
      _ItemHistoricoFormularioState();
}

class _ItemHistoricoFormularioState extends State<ItemHistoricoFormulario> {
  final _chaveFormulario = GlobalKey<FormState>();
  late String _titulo = widget.item.titulo;
  late int _quantidade = widget.item.quantidade;
  late int _preco = widget.item.preco;

  @override
  Widget build(BuildContext context) {
    final porPeso = widget.item.unidadeMedida == 'kg';
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
              'Editar item da compra',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            CampoDeTexto(
              rotulo: 'Título',
              valor: _titulo,
              validadores: [
                () => _titulo.trim().isEmpty
                    ? 'O título é obrigatório.'
                    : null,
              ],
              onChanged: (valor) => _titulo = valor,
            ),
            const SizedBox(height: 12),
            if (porPeso)
              PesoField(
                rotulo: 'Quantidade',
                valorEmGramas: _quantidade,
                onChanged: (valor) => _quantidade = valor ?? 0,
              )
            else
              TextFormField(
                initialValue: _quantidade.toString(),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Quantidade (${widget.item.unidadeMedida})',
                ),
                validator: (_) => _quantidade <= 0
                    ? 'A quantidade deve ser maior que zero.'
                    : null,
                onChanged: (valor) => _quantidade = int.tryParse(valor) ?? 0,
              ),
            const SizedBox(height: 12),
            RealField(
              rotulo: porPeso ? 'Preço por kg' : 'Preço unitário',
              valor: _preco,
              validadores: const [],
              onChanged: (valor) {
                final digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
                _preco = int.tryParse(digitos) ?? 0;
              },
            ),
            const SizedBox(height: 16),
            LinhaBotoesConfirmacao(
              cor: widget.cor,
              onConfirmar: _confirmar,
              onCancelar: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmar() {
    if (!_chaveFormulario.currentState!.validate()) return;
    if (_quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma quantidade válida.')),
      );
      return;
    }
    Navigator.pop(
      context,
      widget.item.copia(
        titulo: _titulo.trim(),
        quantidade: _quantidade,
        preco: _preco,
      ),
    );
  }
}

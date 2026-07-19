import 'package:flutter/material.dart';

import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/mixins/validacoes_mixin.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../model/item_recorrente_model.dart';

class ItemRecorrenteFormulario extends StatefulWidget {
  final int idCategoria;
  final ItemRecorrente? item;

  const ItemRecorrenteFormulario({
    super.key,
    required this.idCategoria,
    this.item,
  });

  static Future<ItemRecorrente?> exibir(
    BuildContext context, {
    required int idCategoria,
    ItemRecorrente? item,
  }) {
    return showModalBottomSheet<ItemRecorrente>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: ItemRecorrenteFormulario(
            idCategoria: idCategoria,
            item: item,
          ),
        ),
      ),
    );
  }

  @override
  State<ItemRecorrenteFormulario> createState() =>
      _ItemRecorrenteFormularioState();
}

class _ItemRecorrenteFormularioState extends State<ItemRecorrenteFormulario>
    with ValidacoesMixin {
  final _chaveFormulario = GlobalKey<FormState>();
  late final ItemRecorrente _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item?.copia() ??
        ItemRecorrente.padrao(idCategoria: widget.idCategoria);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _chaveFormulario,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.item == null
                  ? 'Novo item recorrente'
                  : 'Editar item recorrente',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CampoDeTexto(
              rotulo: 'Título',
              valor: _item.titulo,
              validadores: [
                () => isEmpty(_item.titulo.trim(), 'Obrigatório'),
              ],
              onChanged: (titulo) => _item.titulo = titulo,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TipoMedida>(
              initialValue: _item.tipoMedida,
              decoration: const InputDecoration(labelText: 'Unidade de medida'),
              items: TipoMedida.values
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(TipoMedida.obterRotulo(tipo: tipo)),
                    ),
                  )
                  .toList(),
              onChanged: (tipo) {
                if (tipo != null) {
                  _item.tipoMedida = tipo;
                }
              },
            ),
            const SizedBox(height: 20),
            LinhaBotoesConfirmacao(
              onConfirmar: () {
                if (_chaveFormulario.currentState!.validate()) {
                  _item.titulo = _item.titulo.trim();
                  Navigator.pop(context, _item);
                }
              },
              onCancelar: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

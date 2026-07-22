import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/constants/enums/prioridade.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/mixins/validacoes_mixin.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/campos_formulario/peso_field.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../../listas/controller/listas_controller.dart';
import '../model/item_model.dart';

class ItemFormulario extends StatefulWidget {
  final Item? item;

  const ItemFormulario({super.key, this.item});

  static Future<void> exibir(BuildContext context, {Item? item}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(child: ItemFormulario(item: item)),
      ),
    );
  }

  @override
  State<ItemFormulario> createState() => _ItemFormularioState();
}

class _ItemFormularioState extends State<ItemFormulario> with ValidacoesMixin {
  final _chaveFormulario = GlobalKey<FormState>();
  late Item _item;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item?.copia() ??
        Item(
          idLista: 0,
          idCategoria: 0,
          titulo: '',
          quantidade: 1,
        );
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
          spacing: 12,
          children: [
            Text(
              widget.item == null ? 'Novo Item' : 'Editar Item',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            CampoDeTexto(
              rotulo: 'Título',
              valor: _item.titulo,
              validadores: [() => isEmpty(_item.titulo.trim(), 'Obrigatório')],
              onChanged: (valor) => _item.titulo = valor,
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _item.tipoMedida == TipoMedida.kg
                      ? PesoField(
                          valorEmGramas: _item.quantidade,
                          onChanged: (valor) => _item.quantidade = valor,
                        )
                      : TextFormField(
                          initialValue: _item.quantidade?.toString(),
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Quantidade'),
                          onChanged: (valor) =>
                              _item.quantidade = int.tryParse(valor),
                        ),
                ),
                Expanded(
                  child: DropdownButtonFormField<TipoMedida>(
                    initialValue: _item.tipoMedida,
                    decoration: const InputDecoration(labelText: 'Medida'),
                    items: TipoMedida.values
                        .map(
                          (tipo) => DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.name),
                          ),
                        )
                        .toList(),
                    onChanged: (tipo) {
                      if (tipo != null) {
                        setState(() {
                          _item.tipoMedida = tipo;
                          _item.quantidade = tipo == TipoMedida.kg ? 1000 : 1;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<int>(
              initialValue: _item.idCategoria > 0 ? _item.idCategoria : null,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: context
                  .read<ListasController>()
                  .categorias
                  .map((categoria) => DropdownMenuItem(
                        value: categoria.id,
                        child: Text(categoria.titulo),
                      ))
                  .toList(),
              onChanged: (valor) {
                if (valor != null) _item.idCategoria = valor;
              },
            ),
            DropdownButtonFormField<Prioridade>(
              initialValue: _item.prioridade,
              decoration: const InputDecoration(labelText: 'Prioridade'),
              items: Prioridade.values
                  .map((prioridade) => DropdownMenuItem(
                        value: prioridade,
                        child: Text(_rotuloPrioridade(prioridade)),
                      ))
                  .toList(),
              onChanged: (valor) {
                if (valor != null) _item.prioridade = valor;
              },
            ),
            RealField(
              rotulo: 'Preço unitário (opcional)',
              valor: _item.preco,
              validadores: const [],
              onChanged: (valor) {
                final digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
                _item.preco = digitos.isEmpty
                    ? null
                    : MonetarioUtils.deFormatadoParaInt(formatado: valor);
              },
            ),
            CampoDeTexto(
              rotulo: 'Observação (opcional)',
              valor: _item.observacao ?? '',
              linhas: 2,
              validadores: const [],
              onChanged: (valor) =>
                  _item.observacao = valor.trim().isEmpty ? null : valor,
            ),
            LinhaBotoesConfirmacao(
              onConfirmar: _salvar,
              onCancelar: () {
                if (!_salvando) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _rotuloPrioridade(Prioridade prioridade) => switch (prioridade) {
        Prioridade.neutra => 'Neutra',
        Prioridade.baixa => 'Baixa',
        Prioridade.media => 'Média',
        Prioridade.alta => 'Alta',
      };

  Future<void> _salvar() async {
    if (_salvando || !_chaveFormulario.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final controller = context.read<ListasController>();
      if (widget.item == null) {
        await controller.criarItem(_item);
      } else {
        await controller.editarItem(_item);
      }
      if (!mounted) return;
      context.mostrarSucesso(
        widget.item == null
            ? 'Item adicionado com sucesso.'
            : 'Item editado com sucesso.',
      );
      Navigator.pop(context);
    } catch (erro) {
      if (mounted) context.mostrarErro('Não foi possível salvar o item: $erro');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}

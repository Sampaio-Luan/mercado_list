import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/constants/enums/tipo_snackbar.dart';
import '../../../core/mixins/validacoes_mixin.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/campos_formulario/real_field.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../../../shared/widgets/seletor_de_cor.dart';
import '../controller/listas_controller.dart';
import '../model/lista_model.dart';

class ListaFormulario extends StatefulWidget {
  final Lista? lista;
  final ScaffoldMessengerState? mensageiro;

  const ListaFormulario({super.key, this.lista, this.mensageiro});

  static Future<void> exibir(
    BuildContext context, {
    Lista? lista,
    ScaffoldMessengerState? mensageiro,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: ListaFormulario(lista: lista, mensageiro: mensageiro),
        ),
      ),
    );
  }

  @override
  State<ListaFormulario> createState() => _ListaFormularioState();
}

class _ListaFormularioState extends State<ListaFormulario>
    with ValidacoesMixin {
  final _chaveFormulario = GlobalKey<FormState>();
  late Lista _lista;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _lista = widget.lista?.copia() ?? Lista.padrao();
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
              widget.lista == null ? 'Nova Lista' : 'Editar Lista',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            CampoDeTexto(
              rotulo: 'Título',
              valor: _lista.titulo,
              validadores: [() => isEmpty(_lista.titulo.trim(), 'Obrigatório')],
              onChanged: (valor) => _lista.titulo = valor,
            ),
            CampoDeTexto(
              rotulo: 'Descrição (opcional)',
              valor: _lista.descricao ?? '',
              linhas: 2,
              validadores: const [],
              onChanged: _lista.setDescricao,
            ),
            RealField(
              rotulo: 'Orçamento (opcional)',
              valor: _lista.orcamento,
              validadores: const [],
              onChanged: (valor) {
                final digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');
                _lista.orcamento = digitos.isEmpty
                    ? null
                    : MonetarioUtils.deFormatadoParaInt(formatado: valor);
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cor',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            SeletorDeCor(
              corSelecionada: Cor.obterPorColor(color: _lista.cor),
              onCorSelecionada: (cor) {
                setState(() => _lista.setCor(cor));
              },
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

  Future<void> _salvar() async {
    if (_salvando || !_chaveFormulario.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      final controller = context.read<ListasController>();
      if (widget.lista == null) {
        await controller.criar(_lista);
      } else {
        await controller.editar(_lista);
      }
      if (!mounted) return;
      _mostrarFeedback(
        widget.lista == null
            ? 'Lista criada com sucesso.'
            : 'Lista editada com sucesso.',
        TipoSnackbar.sucesso,
      );
      Navigator.pop(context);
    } catch (erro) {
      if (mounted) {
        _mostrarFeedback(
          'Não foi possível salvar a lista: $erro',
          TipoSnackbar.erro,
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _mostrarFeedback(String mensagem, TipoSnackbar tipo) {
    final mensageiro = widget.mensageiro ?? ScaffoldMessenger.of(context);
    SnackbarService.mostrarNoMensageiro(
      mensageiro: mensageiro,
      context: context,
      mensagem: mensagem,
      tipo: tipo,
    );
  }
}

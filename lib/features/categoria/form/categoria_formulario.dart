import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/mixins/validacoes_mixin.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../../../shared/widgets/seletor_de_cor.dart';
import '../model/categoria_model.dart';
import '../repository/categoria_repository.dart';



class CategoriaFormulario extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaFormulario({super.key, this.categoria});

  @override
  State<CategoriaFormulario> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaFormulario> with ValidacoesMixin {
  final _formKeyCategoria = GlobalKey<FormState>();

  String titulo = '';
  late Categoria categoria;

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      categoria = widget.categoria!;
      titulo = 'Editar Categoria';
    } else {
      categoria = Categoria.padrao();
      titulo = 'Nova Categoria';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriaR = context.read<CategoriasRepository>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKeyCategoria,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              ),
            ),
            CampoDeTexto(
              rotulo: 'Titulo',
              valor: categoria.titulo,
              validadores: [() => isEmpty(categoria.titulo, 'Obrigatório')],
              onChanged: categoria.setTitulo,
            ),
            SeletorDeCor(
              corSelecionada: Cor.obterPorColor(color: categoria.cor),
              onCorSelecionada: (cor) {
                categoria.setCor(cor);
                setState(() {});
              },
            ),
            LinhaBotoesConfirmacao(
              onConfirmar: () async {
                if (_formKeyCategoria.currentState!.validate()) {
                  if (widget.categoria != null) {
                    categoriaR.editar(categoria);
                  } else {
                    await categoriaR.criar(categoria);
                   
                  }
                  String operacao = widget.categoria != null
                      ? 'editada'
                      : 'criada';

                  if (context.mounted) {
                    context.mostrarSucesso('Categoria $operacao com sucesso !');
                    Navigator.pop(context);
                  }
                }
              },
              onCancelar: () {
                context.mostrarErro('Operação cancelada !');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

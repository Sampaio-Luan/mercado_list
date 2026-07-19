import 'package:flutter/material.dart';

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/categoria_padrao_constantes.dart';
import '../../../core/constants/enums/cor.dart';
import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/extensions/dialogo_extension.dart';
import '../../../core/extensions/snackbar_extension.dart';
import '../../../core/mixins/validacoes_mixin.dart';
import '../../../core/services/carregamento_service.dart';
import '../../../shared/widgets/campos_formulario/campo_texto.dart';
import '../../../shared/widgets/linha_botoes_confirmacao.dart';
import '../../../shared/widgets/seletor_de_cor.dart';
import '../controller/categorias_controller.dart';
import '../model/categoria_model.dart';

class CategoriaFormulario extends StatefulWidget {
  final Categoria? categoria;
  final bool retornarResultado;
  final int quantidadeItens;

  const CategoriaFormulario({
    super.key,
    this.categoria,
    this.retornarResultado = false,
    this.quantidadeItens = 0,
  });

  static String construirMensagemExclusao({
    required String tituloCategoria,
    required int quantidadeItens,
  }) {
    if (quantidadeItens <= 0) {
      return 'Deseja excluir a categoria "$tituloCategoria"?';
    }

    final movimentacao =
        quantidadeItens == 1 ? 'item será movido' : 'itens serão movidos';
    return '$quantidadeItens $movimentacao para a categoria padrão '
        '"${CategoriaPadraoConstantes.titulo}". '
        'Deseja excluir a categoria "$tituloCategoria"?';
  }

  static Future<Categoria?> exibirParaResultado(BuildContext context) {
    return showModalBottomSheet<Categoria>(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const SingleChildScrollView(
          child: CategoriaFormulario(retornarResultado: true),
        ),
      ),
    );
  }

  @override
  State<CategoriaFormulario> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaFormulario>
    with ValidacoesMixin {
  final _formKeyCategoria = GlobalKey<FormState>();

  String titulo = '';
  late Categoria categoria;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      categoria = widget.categoria!.copia();
      titulo = 'Editar Categoria';
    } else {
      categoria = Categoria.padrao();
      titulo = 'Nova Categoria';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Form(
        key: _formKeyCategoria,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.categoria == null ? 0 : 48,
                  ),
                  child: Text(
                    titulo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.headlineMedium?.fontSize,
                    ),
                  ),
                ),
                if (widget.categoria != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      tooltip: categoria.categoriaPadrao
                          ? 'A categoria padrão não pode ser excluída'
                          : 'Excluir categoria',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                      ),
                      onPressed:
                          categoria.categoriaPadrao ? null : _confirmarExclusao,
                      icon: Icon(
                        PhosphorIcons.trash,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
            CampoDeTexto(
              rotulo: categoria.categoriaPadrao
                  ? 'Título da categoria padrão'
                  : 'Título',
              valor: categoria.titulo,
              habilitado: !categoria.categoriaPadrao,
              validadores: [() => isEmpty(categoria.titulo, 'Obrigatório')],
              onChanged: (titulo) => categoria.titulo = titulo,
            ),
            SeletorDeCor(
              corSelecionada: Cor.obterPorColor(color: categoria.cor),
              onCorSelecionada: (cor) {
                categoria.setCor(cor);
                setState(() {});
              },
            ),
            LinhaBotoesConfirmacao(
              onConfirmar: _salvar,
              onCancelar: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _salvar() async {
    if (_salvando || !_formKeyCategoria.currentState!.validate()) return;

    categoria.titulo = categoria.titulo.trim();
    if (widget.retornarResultado) {
      Navigator.pop(context, categoria);
      return;
    }

    setState(() => _salvando = true);
    try {
      final controller = context.read<CategoriasController>();
      if (widget.categoria != null) {
        await controller.editarCategoria(categoria);
      } else {
        await controller.criarCategoria(categoria);
      }

      if (!mounted) return;
      final operacao = widget.categoria != null ? 'editada' : 'criada';
      context.mostrarSucesso('Categoria $operacao com sucesso!');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        context.mostrarErro(
          'Não foi possível salvar a categoria. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _confirmarExclusao() async {
    final resultado = await context.confirmar(
      titulo: 'Excluir categoria',
      mensagem: CategoriaFormulario.construirMensagemExclusao(
        tituloCategoria: categoria.titulo,
        quantidadeItens: widget.quantidadeItens,
      ),
      textoConfirmar: 'Excluir',
    );

    if (resultado != ResultadoDialogo.confirmar || !mounted) return;

    final controller = context.read<CategoriasController>();
    try {
      await CarregamentoService.executar<void>(
        context: context,
        titulo: 'Excluindo categoria',
        mensagemSucesso: 'Categoria excluída com sucesso.',
        mensagemErro:
            'Não foi possível excluir a categoria. Nenhuma alteração foi aplicada.',
        duracaoMinima: const Duration(seconds: 5),
        operacao: (atualizar) =>
            controller.excluir(categoria, aoProgredir: atualizar),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      // O Controller registra o erro e o formulário permanece aberto.
    }
  }
}

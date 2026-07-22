import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/enums/tema_app.dart';
import '../../../core/constants/enums/tipo_dialogo.dart';
import '../../../core/constants/enums/tipo_snackbar.dart';
import '../../../core/extensions/dialogo_extension.dart';
import '../../../core/services/snackbar_service.dart';
import '../../../core/utils/monetario_utils.dart';
import '../../categoria/screen/categorias_screen.dart';
import '../../preferencias_usuario/preferencias_provider.dart';
import '../controller/listas_controller.dart';
import '../form/lista_formulario.dart';
import '../model/lista_com_resumo_de_itens_model.dart';
import '../model/lista_model.dart';

enum _AcaoLista { editar, fixar, copiar, compartilhar, excluir }

class ListaDeListasScreen extends StatefulWidget {
  const ListaDeListasScreen({super.key});

  @override
  State<ListaDeListasScreen> createState() => _ListaDeListasScreenState();
}

class _ListaDeListasScreenState extends State<ListaDeListasScreen> {
  final _pesquisa = TextEditingController();
  final _mensageiroDrawer = GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListasController>();
    final preferencias = context.watch<PreferenciasProvider>();
    final resultados = controller.pesquisar(_pesquisa.text);
    final largura = MediaQuery.sizeOf(context).width * .82;

    return Drawer(
      width: largura.clamp(300, 420).toDouble(),
      child: ScaffoldMessenger(
        key: _mensageiroDrawer,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                _CabecalhoDrawer(
                  tema: preferencias.preferencias.tema,
                  aoAlternarTema: () {
                    final atual = preferencias.preferencias.tema;
                    preferencias.alterarTema(
                      atual == TemaApp.claro ? TemaApp.escuro : TemaApp.claro,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 6, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pesquisa,
                          key: const ValueKey('pesquisa-listas'),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Pesquisar listas',
                            prefixIcon: Icon(PhosphorIcons.magnifyingGlass),
                            suffixIcon: _pesquisa.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Limpar pesquisa',
                                    onPressed: () {
                                      _pesquisa.clear();
                                      setState(() {});
                                    },
                                    icon: Icon(PhosphorIcons.x),
                                  ),
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Ordenar listas de A a Z',
                        onPressed: controller.alterandoOrdem
                            ? null
                            : () => _ordenarAlfabeticamente(controller),
                        icon: Icon(PhosphorIcons.sortAscending),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: switch (controller.estado) {
                    EstadoDeTela.carregando => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    EstadoDeTela.erro => _EstadoDrawer(
                        mensagem: controller.mensagemErro ??
                            'Não foi possível carregar as listas.',
                        aoTentarNovamente: controller.carregar,
                      ),
                    EstadoDeTela.carregadaSemDados => const _EstadoDrawer(
                        mensagem: 'Nenhuma lista criada.',
                      ),
                    EstadoDeTela.carregadaComDados when resultados.isEmpty =>
                      const _EstadoDrawer(
                        mensagem: 'Nenhuma lista encontrada para a pesquisa.',
                      ),
                    EstadoDeTela.carregadaComDados =>
                      _construirListasAgrupadas(controller, resultados),
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => ListaFormulario.exibir(
                        context,
                        mensageiro: _mensageiroDrawer.currentState,
                      ),
                      icon: Icon(PhosphorIcons.notePencil),
                      label: const Text('Nova Lista'),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      Icon(PhosphorIcons.stackPlusBold, color: Colors.green),
                  title: const Text('Gerenciar Categorias'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const CategoriasScreen(),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    PhosphorIcons.clockCounterClockwiseBold,
                    color: Colors.blue,
                  ),
                  title: const Text('Histórico de Compras'),
                  onTap: () => _mostrarFeedback(
                    'O histórico de compras estará disponível em breve.',
                    TipoSnackbar.informacao,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirListasAgrupadas(
    ListasController controller,
    List<ListaComResumoDeItens> resultados,
  ) {
    final fixadas = resultados
        .where((resumo) => resumo.lista.fixada)
        .toList(growable: false);
    final outras = resultados
        .where((resumo) => !resumo.lista.fixada)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        if (fixadas.isNotEmpty) ...[
          _CabecalhoGrupoListas(
            key: const ValueKey('grupo-listas-fixadas'),
            titulo: 'Listas fixadas',
            quantidade: fixadas.length,
            icone: PhosphorIcons.pushPinFill,
          ),
          _construirGrupo(
            controller: controller,
            resumos: fixadas,
            deslocamento: 0,
            chave: 'listas-fixadas',
          ),
        ],
        if (outras.isNotEmpty) ...[
          _CabecalhoGrupoListas(
            key: const ValueKey('grupo-outras-listas'),
            titulo: fixadas.isEmpty ? 'Listas' : 'Outras listas',
            quantidade: outras.length,
            icone: PhosphorIcons.listBullets,
          ),
          _construirGrupo(
            controller: controller,
            resumos: outras,
            deslocamento: fixadas.length,
            chave: 'outras-listas',
          ),
        ],
      ],
    );
  }

  Widget _construirGrupo({
    required ListasController controller,
    required List<ListaComResumoDeItens> resumos,
    required int deslocamento,
    required String chave,
  }) {
    return ReorderableListView.builder(
      key: ValueKey(chave),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: _pesquisa.text.isEmpty,
      itemCount: resumos.length,
      onReorderItem: _pesquisa.text.isNotEmpty
          ? (_, _) {}
          : (antigo, novo) => _reordenar(
                controller,
                deslocamento + antigo,
                deslocamento + novo,
              ),
      itemBuilder: (context, index) {
        final resumo = resumos[index];
        return _CartaoLista(
          key: ValueKey('lista-${resumo.lista.id}'),
          resumo: resumo,
          selecionada: resumo.lista.id == controller.idListaSelecionada,
          aoSelecionar: () => _selecionar(resumo.lista),
          aoAcionar: (acao) => _executarAcao(acao, resumo.lista),
        );
      },
    );
  }

  Future<void> _selecionar(Lista lista) async {
    await context.read<ListasController>().selecionar(lista.id!);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reordenar(
    ListasController controller,
    int antigo,
    int novo,
  ) async {
    try {
      await controller.reordenar(antigo, novo);
    } catch (_) {
      if (mounted) {
        _mostrarFeedback(
          'Não foi possível salvar a nova ordem das listas.',
          TipoSnackbar.erro,
        );
      }
    }
  }

  Future<void> _ordenarAlfabeticamente(ListasController controller) async {
    try {
      await controller.ordenarAlfabeticamente();
      if (mounted) {
        _mostrarFeedback(
          'Listas ordenadas de A a Z.',
          TipoSnackbar.sucesso,
        );
      }
    } catch (_) {
      if (mounted) {
        _mostrarFeedback(
          'Não foi possível ordenar as listas.',
          TipoSnackbar.erro,
        );
      }
    }
  }

  Future<void> _executarAcao(_AcaoLista acao, Lista lista) async {
    final controller = context.read<ListasController>();
    try {
      switch (acao) {
        case _AcaoLista.editar:
          await ListaFormulario.exibir(
            context,
            lista: lista,
            mensageiro: _mensageiroDrawer.currentState,
          );
        case _AcaoLista.fixar:
          await controller.alternarFixacao(lista);
          if (mounted) {
            _mostrarFeedback(
              lista.fixada ? 'Lista desfixada.' : 'Lista fixada no topo.',
              TipoSnackbar.sucesso,
            );
          }
        case _AcaoLista.copiar:
          await controller.copiar(lista);
          if (mounted) {
            _mostrarFeedback(
              'Cópia criada e aberta.',
              TipoSnackbar.sucesso,
            );
          }
        case _AcaoLista.compartilhar:
          if (mounted) {
            _mostrarFeedback(
              'O compartilhamento estará disponível em breve.',
              TipoSnackbar.informacao,
            );
          }
        case _AcaoLista.excluir:
          await _confirmarExclusao(lista);
      }
    } catch (erro) {
      if (mounted) _mostrarFeedback(erro.toString(), TipoSnackbar.erro);
    }
  }

  Future<void> _confirmarExclusao(Lista lista) async {
    final resultado = await context.confirmar(
      titulo: 'Excluir lista',
      mensagem: 'A lista "${lista.titulo}" e todos os seus itens serão '
          'removidos. O histórico de compras não será afetado. Deseja continuar?',
      textoConfirmar: 'Excluir lista',
    );
    if (resultado != ResultadoDialogo.confirmar || !mounted) return;
    await context.read<ListasController>().excluir(lista);
    if (mounted) {
      _mostrarFeedback(
        'Lista e itens excluídos.',
        TipoSnackbar.sucesso,
      );
    }
  }

  void _mostrarFeedback(String mensagem, TipoSnackbar tipo) {
    final mensageiro = _mensageiroDrawer.currentState;
    if (mensageiro == null) return;
    SnackbarService.mostrarNoMensageiro(
      mensageiro: mensageiro,
      context: context,
      mensagem: mensagem,
      tipo: tipo,
    );
  }
}

class _CabecalhoGrupoListas extends StatelessWidget {
  final String titulo;
  final int quantidade;
  final IconData icone;

  const _CabecalhoGrupoListas({
    super.key,
    required this.titulo,
    required this.quantidade,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 4),
      child: Row(
        children: [
          Icon(icone, size: 16, color: cores.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cores.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            '$quantidade',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cores.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _CabecalhoDrawer extends StatelessWidget {
  final TemaApp tema;
  final VoidCallback aoAlternarTema;

  const _CabecalhoDrawer({
    required this.tema,
    required this.aoAlternarTema,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/padrao2.jpg'),
          fit: BoxFit.cover,
          opacity: .22,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              'Mercado List',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Alternar tema',
            onPressed: aoAlternarTema,
            icon: Icon(
              tema == TemaApp.claro
                  ? PhosphorIcons.moonStarsFill
                  : PhosphorIcons.sunFill,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoLista extends StatelessWidget {
  final ListaComResumoDeItens resumo;
  final bool selecionada;
  final VoidCallback aoSelecionar;
  final ValueChanged<_AcaoLista> aoAcionar;

  const _CartaoLista({
    super.key,
    required this.resumo,
    required this.selecionada,
    required this.aoSelecionar,
    required this.aoAcionar,
  });

  @override
  Widget build(BuildContext context) {
    final lista = resumo.lista;
    final cores = Theme.of(context).colorScheme;
    final corConteudo =
        selecionada ? cores.onPrimaryContainer : cores.onSurface;
    final corConteudoSecundario = selecionada
        ? cores.onPrimaryContainer.withAlpha(190)
        : cores.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      color: selecionada ? cores.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoSelecionar,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularPercentIndicator(
                    radius: 18,
                    lineWidth: 5,
                    percent: resumo.progresso.clamp(0, 1).toDouble(),
                    progressColor: lista.cor,
                    backgroundColor: lista.cor.withAlpha(45),
                    center: resumo.quantidadeItens > 0 && resumo.progresso == 1
                        ? Icon(
                            PhosphorIcons.checkBold,
                            size: 14,
                            color: lista.cor,
                          )
                        : null,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${resumo.quantidadeItensMarcados}/${resumo.quantidadeItens}',
                    key: ValueKey('contador-itens-${lista.id}'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 10,
                      color: corConteudoSecundario,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (lista.fixada) ...[
                          Icon(
                            PhosphorIcons.pushPinFill,
                            size: 14,
                            color: corConteudo,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            lista.titulo,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: corConteudo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lista.descricao != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          lista.descricao!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: corConteudoSecundario,
                                  ),
                        ),
                      ),
                    if (lista.orcamento != null)
                      Text(
                        'Orçamento: ${MonetarioUtils.formatarIntToMoeda(lista.orcamento!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: corConteudoSecundario,
                            ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<_AcaoLista>(
                tooltip: 'Ações da lista',
                iconColor: corConteudo,
                onSelected: aoAcionar,
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: _AcaoLista.editar,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: _AcaoLista.fixar,
                    child: Text(lista.fixada ? 'Desfixar' : 'Fixar no topo'),
                  ),
                  const PopupMenuItem(
                    value: _AcaoLista.copiar,
                    child: Text('Criar cópia'),
                  ),
                  const PopupMenuItem(
                    value: _AcaoLista.compartilhar,
                    child: Text('Compartilhar'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: _AcaoLista.excluir,
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoDrawer extends StatelessWidget {
  final String mensagem;
  final Future<void> Function()? aoTentarNovamente;

  const _EstadoDrawer({required this.mensagem, this.aoTentarNovamente});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(PhosphorIcons.listBullets, size: 36),
            Text(mensagem, textAlign: TextAlign.center),
            if (aoTentarNovamente != null)
              OutlinedButton(
                onPressed: aoTentarNovamente,
                child: const Text('Tentar novamente'),
              ),
          ],
        ),
      ),
    );
  }
}

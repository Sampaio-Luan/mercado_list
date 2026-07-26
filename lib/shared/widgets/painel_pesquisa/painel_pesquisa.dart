import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'cabecalho_painel_pesquisa.dart';
import 'campo_painel_pesquisa.dart';
import 'controlador_painel_pesquisa.dart';
import 'contexto_item_pesquisa.dart';
import 'estilo_painel_pesquisa.dart';
import 'item_padrao_painel_pesquisa.dart';
import 'modo_interacao_painel.dart';
import 'rodape_painel_pesquisa.dart';

/// Painel inferior genérico para pesquisar, selecionar ou gerenciar itens de
/// qualquer tipo `T`.
///
/// ### Principais recursos:
/// - Pesquisa em tempo real com ordenação por relevância (Levenshtein).
/// - Destaque visual das partes do texto coincidentes com a pesquisa.
/// - Modos sem seleção, seleção única ou múltipla.
/// - Renderização customizada de itens e ações no cabeçalho.
/// - Atualização da lista durante a exibição através do controlador.
/// - Cabeçalho e barra de pesquisa fixos (não rolam com a lista).
/// - Arrastável com pontos de ancoragem em 30%, 60%, 90% e 100% da tela.
/// - Botão de alternância para tela cheia.
/// - Sobe automaticamente acima do teclado.
/// - Suporte a carregamento assíncrono via `Future<List<T>>`.
/// - Totalmente estilizável através de [EstiloPainelPesquisa].
///
/// ### Uso básico:
/// ```dart
/// final resultado = await PainelPesquisa.exibir<MeuModelo>(
///   context: context,
///   itens: minhaListaDeItens,
///   obterTextoPesquisa: (item) => item.nome,
///   modoSelecao: ModoInteracaoPainel.unica,
/// );
/// ```
class PainelPesquisa<T> extends StatefulWidget {
  const PainelPesquisa({
    super.key,
    required this.itens,
    required this.obterTextoPesquisa,
    this.obterIdentificador,
    this.construirItem,
    this.construirAcoesCabecalho,
    this.construirRodape,
    this.gerenciarGestosItemCustomizado = true,
    this.carregarItensAssincronamente,
    this.modoSelecao = ModoInteracaoPainel.multipla,
    this.itensSelecionadosInicialmente = const [],
    this.titulo = 'Pesquisar',
    this.textoPlaceholderPesquisa = 'Pesquisar...',
    this.textoListaVazia = 'Nenhum item disponível.',
    this.textoSemResultados = 'Nenhum resultado encontrado para a pesquisa.',
    this.textoBotaoConfirmar = 'Confirmar seleção',
    this.estilo = const EstiloPainelPesquisa(),
    this.obterTextoSubtitulo,
    this.construirIconeLideranca,
    this.exibirRodapeConfirmacao = true,
    this.pontuacaoMinimaRelevancia = 0.5,
    this.aoConfirmarSelecaoMultipla,
    this.aoSelecionarItemUnico,
  });

  /// Lista síncrona de itens a serem exibidos. Ignorada quando
  /// [carregarItensAssincronamente] é fornecido.
  final List<T> itens;

  /// Função que extrai o texto de exibição (e de pesquisa) de cada item.
  final String Function(T item) obterTextoPesquisa;

  /// Identificador estável usado para atualizar, remover, selecionar e
  /// preservar a identidade visual de itens mutáveis.
  final Object? Function(T item)? obterIdentificador;

  /// Renderer opcional para cards, menus de contexto ou qualquer outro
  /// widget. Quando omitido, o painel usa sua linha padrão com destaque.
  final ConstrutorItemPesquisa<T>? construirItem;

  /// Ações opcionais apresentadas no cabeçalho, antes dos botões de
  /// expandir e fechar.
  final ConstrutorAcoesPainel<T>? construirAcoesCabecalho;

  final ConstrutorRodapePainel<T>? construirRodape;

  final bool gerenciarGestosItemCustomizado;

  /// Função opcional para carregamento assíncrono da lista de itens.
  /// Quando fornecida, o componente exibe um indicador de carregamento
  /// enquanto o `Future` é resolvido.
  final Future<List<T>> Function()? carregarItensAssincronamente;

  /// Define se a seleção é única ou múltipla. Padrão: múltipla.
  final ModoInteracaoPainel modoSelecao;

  /// Itens que devem iniciar já selecionados ao abrir o bottom sheet.
  final List<T> itensSelecionadosInicialmente;

  /// Título exibido no cabeçalho fixo.
  final String titulo;

  /// Texto de dica exibido no campo de pesquisa quando vazio.
  final String textoPlaceholderPesquisa;

  /// Mensagem exibida quando a lista completa de itens está vazia.
  final String textoListaVazia;

  /// Mensagem exibida quando a pesquisa não encontra nenhum resultado.
  final String textoSemResultados;

  /// Texto do botão de confirmação (apenas no modo de seleção múltipla).
  final String textoBotaoConfirmar;

  /// Conjunto de propriedades visuais customizáveis.
  final EstiloPainelPesquisa estilo;

  /// Função opcional para obter um subtítulo exibido abaixo do texto
  /// principal de cada item.
  final String? Function(T item)? obterTextoSubtitulo;

  /// Função opcional para construir um widget de liderança (ícone, avatar,
  /// imagem etc.) exibido antes do texto de cada item.
  final Widget? Function(T item)? construirIconeLideranca;

  /// Define se o rodapé com botão de confirmação deve ser exibido no modo
  /// de seleção múltipla. No modo de seleção única, o rodapé nunca é
  /// exibido, pois a seleção é confirmada imediatamente ao tocar no item.
  final bool exibirRodapeConfirmacao;

  /// Pontuação mínima (0.0 a 1.0) de relevância para um item aparecer nos
  /// resultados filtrados. Itens com prefixo ou substring correspondentes
  /// sempre passam (pontuação ≥ 0.92); este valor afeta apenas o quão
  /// tolerante é a busca fuzzy para erros de digitação. Padrão: 0.5.
  final double pontuacaoMinimaRelevancia;

  /// Callback interno chamado ao confirmar a seleção múltipla (uso
  /// principalmente através do método estático [exibir]).
  final void Function(List<T> itensSelecionados)? aoConfirmarSelecaoMultipla;

  /// Callback interno chamado ao selecionar um item no modo único (uso
  /// principalmente através do método estático [exibir]).
  final void Function(T itemSelecionado)? aoSelecionarItemUnico;

  /// Exibe o `PainelPesquisa<T>` em um `showModalBottomSheet`
  /// já configurado com todos os comportamentos de arraste, teclado e
  /// tela cheia, retornando os itens selecionados pelo usuário.
  ///
  /// No [ModoInteracaoPainel.unica], retorna um único item (`T?`) ou `null` caso
  /// o usuário feche o bottom sheet sem selecionar nada.
  ///
  /// No [ModoInteracaoPainel.multipla], retorna a lista de itens selecionados
  /// (`List<T>`) ao confirmar, ou `null` caso o usuário cancele.
  static Future<Object?> exibir<T>({
    required BuildContext context,
    required String Function(T item) obterTextoPesquisa,
    Object? Function(T item)? obterIdentificador,
    ConstrutorItemPesquisa<T>? construirItem,
    ConstrutorAcoesPainel<T>? construirAcoesCabecalho,
    ConstrutorRodapePainel<T>? construirRodape,
    bool gerenciarGestosItemCustomizado = true,
    List<T> itens = const [],
    Future<List<T>> Function()? carregarItensAssincronamente,
    ModoInteracaoPainel modoSelecao = ModoInteracaoPainel.multipla,
    List<T> itensSelecionadosInicialmente = const [],
    String titulo = 'Pesquisar',
    String textoPlaceholderPesquisa = 'Pesquisar...',
    String textoListaVazia = 'Nenhum item disponível.',
    String textoSemResultados = 'Nenhum resultado encontrado para a pesquisa.',
    String textoBotaoConfirmar = 'Confirmar seleção',
    EstiloPainelPesquisa estilo = const EstiloPainelPesquisa(),
    String? Function(T item)? obterTextoSubtitulo,
    Widget? Function(T item)? construirIconeLideranca,
    bool exibirRodapeConfirmacao = true,
    double pontuacaoMinimaRelevancia = 0.5,
    bool usarFundoBarreiraTransparente = false,
    bool fecharAoTocarFora = true,
    bool fecharAoArrastar = true,
    ThemeData? tema,
  }) {
    return showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: usarFundoBarreiraTransparente
          ? Colors.transparent
          : Colors.black.withValues(alpha: 0.5),
      isDismissible: fecharAoTocarFora,
      enableDrag: fecharAoArrastar,
      builder: (contextoConstrucao) {
        return Theme(
          data: tema ?? Theme.of(contextoConstrucao),
          child: PainelPesquisa<T>(
            itens: itens,
            obterTextoPesquisa: obterTextoPesquisa,
            obterIdentificador: obterIdentificador,
            construirItem: construirItem,
            construirAcoesCabecalho: construirAcoesCabecalho,
            construirRodape: construirRodape,
            gerenciarGestosItemCustomizado: gerenciarGestosItemCustomizado,
            carregarItensAssincronamente: carregarItensAssincronamente,
            modoSelecao: modoSelecao,
            itensSelecionadosInicialmente: itensSelecionadosInicialmente,
            titulo: titulo,
            textoPlaceholderPesquisa: textoPlaceholderPesquisa,
            textoListaVazia: textoListaVazia,
            textoSemResultados: textoSemResultados,
            textoBotaoConfirmar: textoBotaoConfirmar,
            estilo: estilo,
            obterTextoSubtitulo: obterTextoSubtitulo,
            construirIconeLideranca: construirIconeLideranca,
            exibirRodapeConfirmacao: exibirRodapeConfirmacao,
            pontuacaoMinimaRelevancia: pontuacaoMinimaRelevancia,
            aoConfirmarSelecaoMultipla: (itensSelecionados) {
              Navigator.of(contextoConstrucao).pop(itensSelecionados);
            },
            aoSelecionarItemUnico: (itemSelecionado) {
              Navigator.of(contextoConstrucao).pop(itemSelecionado);
            },
          ),
        );
      },
    );
  }

  @override
  State<PainelPesquisa<T>> createState() => _EstadoPainelPesquisa<T>();
}

class _EstadoPainelPesquisa<T> extends State<PainelPesquisa<T>> {
  /// Controlador do `DraggableScrollableSheet`, usado para programaticamente
  /// alternar entre tela cheia e o tamanho anterior.
  final DraggableScrollableController _controladorArraste =
      DraggableScrollableController();

  /// Controlador de texto do campo de pesquisa.
  final TextEditingController _controladorTextoPesquisa =
      TextEditingController();

  /// Controlador de estado da pesquisa e seleção de itens.
  late ControladorPainelPesquisa<T> _controladorPesquisa;

  /// Último tamanho (fração da tela) ocupado antes de entrar em tela
  /// cheia, usado para restaurar ao tocar em "recolher".
  double _ultimoTamanhoAntesDeTelaCheia = AlturasPainelPesquisa.inicial;

  /// Indica se o bottom sheet está atualmente em modo tela cheia.
  bool _estaEmTelaCheia = false;

  /// Evita agendar mais de uma sincronização durante o mesmo quadro.
  bool _sincronizacaoTelaCheiaAgendada = false;

  @override
  void initState() {
    super.initState();

    _controladorPesquisa = ControladorPainelPesquisa<T>(
      itens: widget.itens,
      obterTextoPesquisa: widget.obterTextoPesquisa,
      obterIdentificador: widget.obterIdentificador,
      modoSelecao: widget.modoSelecao,
      itensSelecionadosInicialmente: widget.itensSelecionadosInicialmente,
      pontuacaoMinimaRelevancia: widget.pontuacaoMinimaRelevancia,
    );

    _controladorArraste.addListener(_aoAlterarTamanhoArraste);

    if (widget.carregarItensAssincronamente != null) {
      _carregarItensDeFormaAssincrona();
    }
  }

  @override
  void dispose() {
    _controladorArraste.removeListener(_aoAlterarTamanhoArraste);
    _controladorArraste.dispose();
    _controladorTextoPesquisa.dispose();
    _controladorPesquisa.dispose();
    super.dispose();
  }

  /// Executa o carregamento assíncrono de itens fornecido pelo usuário do
  /// componente, atualizando o estado de carregamento e tratando erros.
  Future<void> _carregarItensDeFormaAssincrona() async {
    _controladorPesquisa.definirEstaCarregando(true);
    _controladorPesquisa.definirMensagemErroCarregamento(null);

    try {
      final itensCarregados = await widget.carregarItensAssincronamente!();
      if (!mounted) return;
      _controladorPesquisa.substituirItens(itensCarregados);
    } catch (erroCapturado) {
      if (!mounted) return;
      _controladorPesquisa.definirMensagemErroCarregamento(
        'Não foi possível carregar os itens. Tente novamente.',
      );
    } finally {
      if (mounted) {
        _controladorPesquisa.definirEstaCarregando(false);
      }
    }
  }

  /// Mantém [_estaEmTelaCheia] sincronizado com o tamanho real do painel,
  /// permitindo que o ícone do cabeçalho reflita corretamente o estado
  /// mesmo quando o usuário arrasta manualmente até o topo.
  void _aoAlterarTamanhoArraste() {
    if (!_controladorArraste.isAttached) return;

    final estaEmTelaCheiaAgora =
        _controladorArraste.size >= AlturasPainelPesquisa.telaCheia - 0.01;
    if (estaEmTelaCheiaAgora == _estaEmTelaCheia ||
        _sincronizacaoTelaCheiaAgendada) {
      return;
    }

    _sincronizacaoTelaCheiaAgendada = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sincronizacaoTelaCheiaAgendada = false;
      if (!mounted || !_controladorArraste.isAttached) return;

      final estaEmTelaCheiaAposQuadro =
          _controladorArraste.size >= AlturasPainelPesquisa.telaCheia - 0.01;
      if (estaEmTelaCheiaAposQuadro != _estaEmTelaCheia) {
        setState(() => _estaEmTelaCheia = estaEmTelaCheiaAposQuadro);
      }
    });
  }

  /// Alterna entre o modo tela cheia e o último tamanho conhecido antes
  /// de entrar em tela cheia, com animação suave.
  ///
  /// Verifica [DraggableScrollableController.isAttached] antes de chamar
  /// `animateTo`: chamar esse método antes do sheet estar completamente
  /// montado lança uma exceção que, sem essa verificação, faz o toque no
  /// botão parecer "não fazer nada".
  void _alternarTelaCheia() {
    if (!_controladorArraste.isAttached) return;

    if (_estaEmTelaCheia) {
      _controladorArraste.animateTo(
        _ultimoTamanhoAntesDeTelaCheia,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _ultimoTamanhoAntesDeTelaCheia = _controladorArraste.size;
      _controladorArraste.animateTo(
        AlturasPainelPesquisa.telaCheia,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  /// Trata o toque em um item da lista, respeitando o modo de seleção
  /// configurado. No modo único, confirma e fecha imediatamente.
  void _aoTocarItem(T item) {
    _controladorPesquisa.alternarSelecaoItem(item);

    if (widget.modoSelecao == ModoInteracaoPainel.unica) {
      widget.aoSelecionarItemUnico?.call(item);
    }
  }

  /// Confirma a seleção múltipla atual, delegando ao callback fornecido.
  void _confirmarSelecaoMultipla() {
    widget.aoConfirmarSelecaoMultipla
        ?.call(_controladorPesquisa.itensSelecionados.toList());
  }

  @override
  Widget build(BuildContext context) {
    final temaAtual = Theme.of(context);
    final alturaTeclado = MediaQuery.of(context).viewInsets.bottom;
    final tecladoAberto = alturaTeclado > 0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 120),
      padding: EdgeInsets.only(bottom: alturaTeclado),
      child: DraggableScrollableSheet(
        controller: _controladorArraste,
        initialChildSize: tecladoAberto
            ? AlturasPainelPesquisa.telaCheia
            : AlturasPainelPesquisa.inicial,
        minChildSize: tecladoAberto
            ? AlturasPainelPesquisa.telaCheia
            : AlturasPainelPesquisa.inicial,
        maxChildSize: AlturasPainelPesquisa.telaCheia,
        snap: !tecladoAberto,
        snapSizes: tecladoAberto ? null : AlturasPainelPesquisa.todos,
        builder: (contextoConstrucao, controladorRolagem) {
          return Container(
            decoration: BoxDecoration(
              color: widget.estilo.corFundo ?? temaAtual.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.estilo.raioBordaSuperior),
                topRight: Radius.circular(widget.estilo.raioBordaSuperior),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: widget.estilo.elevacao,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: ScaffoldMessenger(
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    _CabecalhoReativoPainel<T>(
                      painel: widget,
                      controlador: _controladorPesquisa,
                      estaEmTelaCheia: _estaEmTelaCheia,
                      aoAlternarTelaCheia: _alternarTelaCheia,
                      aoFechar: () => Navigator.of(context).pop(),
                    ),
                    CampoPainelPesquisa(
                      controladorTexto: _controladorTextoPesquisa,
                      aoAlterarTexto:
                          _controladorPesquisa.atualizarTermoPesquisa,
                      aoLimparTexto: () {
                        _controladorTextoPesquisa.clear();
                        _controladorPesquisa.limparPesquisa();
                      },
                      estilo: widget.estilo,
                      textoPlaceholder: widget.textoPlaceholderPesquisa,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: _ConteudoPainelPesquisa<T>(
                        painel: widget,
                        controlador: _controladorPesquisa,
                        controladorRolagem: controladorRolagem,
                        aoTocarItem: _aoTocarItem,
                        aoConfirmarSelecaoMultipla: _confirmarSelecaoMultipla,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CabecalhoReativoPainel<T> extends StatelessWidget {
  final PainelPesquisa<T> painel;
  final ControladorPainelPesquisa<T> controlador;
  final bool estaEmTelaCheia;
  final VoidCallback aoAlternarTelaCheia;
  final VoidCallback aoFechar;

  const _CabecalhoReativoPainel({
    required this.painel,
    required this.controlador,
    required this.estaEmTelaCheia,
    required this.aoAlternarTelaCheia,
    required this.aoFechar,
  });

  @override
  Widget build(BuildContext context) {
    final construirAcoes = painel.construirAcoesCabecalho;
    if (construirAcoes == null) {
      return CabecalhoPainelPesquisa(
        titulo: painel.titulo,
        estaEmTelaCheia: estaEmTelaCheia,
        aoAlternarTelaCheia: aoAlternarTelaCheia,
        aoFechar: aoFechar,
        estilo: painel.estilo,
      );
    }

    return ListenableBuilder(
      listenable: controlador,
      builder: (contextoOuvinte, _) => CabecalhoPainelPesquisa(
        titulo: painel.titulo,
        estaEmTelaCheia: estaEmTelaCheia,
        aoAlternarTelaCheia: aoAlternarTelaCheia,
        aoFechar: aoFechar,
        estilo: painel.estilo,
        acoes: construirAcoes(contextoOuvinte, controlador),
      ),
    );
  }
}

class _ConteudoPainelPesquisa<T> extends StatelessWidget {
  final PainelPesquisa<T> painel;
  final ControladorPainelPesquisa<T> controlador;
  final ScrollController controladorRolagem;
  final ValueChanged<T> aoTocarItem;
  final VoidCallback aoConfirmarSelecaoMultipla;

  const _ConteudoPainelPesquisa({
    required this.painel,
    required this.controlador,
    required this.controladorRolagem,
    required this.aoTocarItem,
    required this.aoConfirmarSelecaoMultipla,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controlador,
      builder: (contextoOuvinte, _) {
        final itensFiltrados = controlador.itensFiltrados;

        return Column(
          children: [
            Expanded(
              child: switch (controlador) {
                _ when controlador.estaCarregando => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                _ when controlador.mensagemErroCarregamento != null =>
                  EstadoVazioPainelPesquisa(
                    mensagem: controlador.mensagemErroCarregamento!,
                    icone: PhosphorIcons.warningCircle,
                  ),
                _ when controlador.naoHaItensDisponiveis =>
                  EstadoVazioPainelPesquisa(
                    mensagem: painel.textoListaVazia,
                  ),
                _ when itensFiltrados.isEmpty => EstadoVazioPainelPesquisa(
                    mensagem: painel.textoSemResultados,
                  ),
                _ => ListView.builder(
                    controller: controladorRolagem,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: itensFiltrados.length,
                    itemBuilder: (contextoItem, indice) {
                      final item = itensFiltrados[indice];
                      final textoExibicao = painel.obterTextoPesquisa(item);
                      final textoSubtitulo =
                          painel.obterTextoSubtitulo?.call(item);
                      final iconeLideranca =
                          painel.construirIconeLideranca?.call(item);
                      final selecionado = controlador.itemEstaSelecionado(item);
                      final contextoResultado = ContextoItemPesquisa<T>(
                        item: item,
                        termoPesquisa: controlador.termoPesquisa,
                        selecionado: selecionado,
                        controlador: controlador,
                      );
                      final itemCustomizado = painel.construirItem?.call(
                        contextoItem,
                        contextoResultado,
                      );
                      final conteudoItem = itemCustomizado ??
                          ItemPadraoPainelPesquisa<T>(
                            item: item,
                            textoExibicao: textoExibicao,
                            textoPesquisa: controlador.termoPesquisa,
                            estaSelecionado: selecionado,
                            modoSelecao: painel.modoSelecao,
                            aoTocarItem: () => aoTocarItem(item),
                            estilo: painel.estilo,
                            textoSubtitulo: textoSubtitulo,
                            iconeLideranca: iconeLideranca,
                          );

                      return KeyedSubtree(
                        key: ValueKey(
                          painel.obterIdentificador?.call(item) ?? item,
                        ),
                        child: itemCustomizado == null ||
                                !painel.gerenciarGestosItemCustomizado ||
                                painel.modoSelecao ==
                                    ModoInteracaoPainel.semSelecao
                            ? conteudoItem
                            : Semantics(
                                selected: contextoResultado.selecionado,
                                button: true,
                                child: InkWell(
                                  onTap: () => aoTocarItem(item),
                                  child: conteudoItem,
                                ),
                              ),
                      );
                    },
                  ),
              },
            ),
            if (painel.modoSelecao == ModoInteracaoPainel.multipla)
              if (painel.construirRodape != null)
                painel.construirRodape!(contextoOuvinte, controlador)
              else if (painel.exibirRodapeConfirmacao)
                RodapePainelPesquisa(
                  quantidadeSelecionados: controlador.itensSelecionados.length,
                  aoConfirmar: aoConfirmarSelecaoMultipla,
                  textoBotaoConfirmar: painel.textoBotaoConfirmar,
                ),
          ],
        );
      },
    );
  }
}

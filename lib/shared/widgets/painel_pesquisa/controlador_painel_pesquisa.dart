import 'package:flutter/foundation.dart';

import 'modo_interacao_painel.dart';
import 'similaridade_texto.dart';

/// Controlador responsável por gerenciar o estado interno do
/// `PainelPesquisa<T>`: lista completa de itens, termo de
/// pesquisa atual, itens filtrados/ordenados por relevância e os itens
/// atualmente selecionados.
///
/// Estende [ChangeNotifier] para notificar a interface sempre que o
/// estado relevante for alterado, seguindo o padrão idiomático do
/// Flutter para gerenciamento de estado local e reutilizável.
class ControladorPainelPesquisa<T> extends ChangeNotifier {
  ControladorPainelPesquisa({
    required List<T> itens,
    required this._obterTextoPesquisa,
    required this._modoSelecao,
    Object? Function(T item)? obterIdentificador,
    List<T> itensSelecionadosInicialmente = const [],
    this._pontuacaoMinimaRelevancia = 0.5,
  })  : _itensCompletos = List<T>.from(itens),
        _obterIdentificador = obterIdentificador ?? ((item) => item as Object?),
        _itensSelecionados = {...itensSelecionadosInicialmente} {
    if (_modoSelecao == ModoInteracaoPainel.semSelecao) {
      _itensSelecionados.clear();
    } else if (_modoSelecao == ModoInteracaoPainel.unica &&
        _itensSelecionados.length > 1) {
      final primeiroItem = _itensSelecionados.first;
      _itensSelecionados
        ..clear()
        ..add(primeiroItem);
    }
    _itensFiltrados = List<T>.from(_itensCompletos);
  }

  /// Lista completa e original de itens (não filtrada).
  List<T> _itensCompletos;

  /// Função fornecida pelo usuário do componente para obter o texto de
  /// exibição de cada item.
  final String Function(T item) _obterTextoPesquisa;

  final Object? Function(T item) _obterIdentificador;

  /// Modo de seleção atual (única ou múltipla).
  final ModoInteracaoPainel _modoSelecao;

  /// Pontuação mínima de relevância (0.0 a 1.0) para que um item apareça
  /// nos resultados filtrados. Evita exibir itens completamente
  /// irrelevantes quando a busca fuzzy não encontra boas correspondências.
  final double _pontuacaoMinimaRelevancia;

  /// Termo de pesquisa atualmente digitado pelo usuário.
  String _termoPesquisa = '';

  /// Conjunto de itens atualmente selecionados.
  final Set<T> _itensSelecionados;

  /// Lista de itens já filtrados e ordenados por relevância em relação
  /// ao [_termoPesquisa] atual.
  late List<T> _itensFiltrados;

  /// Indica se uma operação assíncrona de carregamento está em andamento.
  bool _estaCarregando = false;

  /// Mensagem de erro ocorrido durante o carregamento assíncrono, se houver.
  String? _mensagemErroCarregamento;

  /// Termo de pesquisa atual (somente leitura).
  String get termoPesquisa => _termoPesquisa;

  /// Lista filtrada e ordenada por relevância, exposta como imutável.
  List<T> get itensFiltrados => List.unmodifiable(_itensFiltrados);

  /// Conjunto de itens selecionados, exposto como imutável.
  Set<T> get itensSelecionados => Set.unmodifiable(_itensSelecionados);

  /// Modo de seleção configurado para este controlador.
  ModoInteracaoPainel get modoSelecao => _modoSelecao;

  /// Indica se há uma operação de carregamento assíncrono em andamento.
  bool get estaCarregando => _estaCarregando;

  /// Mensagem de erro do último carregamento, caso tenha falhado.
  String? get mensagemErroCarregamento => _mensagemErroCarregamento;

  /// Indica se a lista completa de itens está vazia (sem considerar o
  /// filtro de pesquisa atual).
  bool get naoHaItensDisponiveis => _itensCompletos.isEmpty;

  /// Verifica se um determinado [item] está atualmente selecionado.
  bool itemEstaSelecionado(T item) =>
      _itensSelecionados.any((selecionado) => _mesmoItem(selecionado, item));

  /// Atualiza o termo de pesquisa e recalcula a lista filtrada/ordenada.
  /// Chamado a cada alteração no campo de texto da barra de pesquisa.
  void atualizarTermoPesquisa(String novoTermo) {
    _termoPesquisa = novoTermo;
    _recalcularItensFiltrados();
    notifyListeners();
  }

  /// Limpa o termo de pesquisa atual, restaurando a lista completa.
  void limparPesquisa() {
    _termoPesquisa = '';
    _recalcularItensFiltrados();
    notifyListeners();
  }

  /// Substitui a lista completa de itens (por exemplo, após um
  /// carregamento assíncrono bem-sucedido) e recalcula o filtro atual.
  void substituirItens(List<T> novosItens) {
    _itensCompletos = List<T>.from(novosItens);
    _removerSelecoesInexistentes();
    _recalcularItensFiltrados();
    notifyListeners();
  }

  void adicionarItem(T item) {
    final indiceExistente = _indiceDoItem(item);
    if (indiceExistente >= 0) {
      _itensCompletos[indiceExistente] = item;
    } else {
      _itensCompletos.add(item);
    }
    _recalcularItensFiltrados();
    notifyListeners();
  }

  void atualizarItem(T itemAnterior, T itemAtualizado) {
    final indice = _indiceDoItem(itemAnterior);
    if (indice < 0) {
      throw StateError('O item que será atualizado não está no painel.');
    }

    final estavaSelecionado = itemEstaSelecionado(itemAnterior);
    _itensSelecionados.removeWhere(
      (item) => _mesmoItem(item, itemAnterior),
    );
    _itensCompletos[indice] = itemAtualizado;
    if (estavaSelecionado) {
      _itensSelecionados.add(itemAtualizado);
    }
    _recalcularItensFiltrados();
    notifyListeners();
  }

  void removerItem(T item) {
    _itensCompletos.removeWhere((existente) => _mesmoItem(existente, item));
    _itensSelecionados.removeWhere(
      (selecionado) => _mesmoItem(selecionado, item),
    );
    _recalcularItensFiltrados();
    notifyListeners();
  }

  void notificarItemAlterado() {
    _recalcularItensFiltrados();
    notifyListeners();
  }

  /// Define o estado de carregamento assíncrono, usado enquanto um
  /// `Future<List<T>>` de itens está sendo resolvido.
  void definirEstaCarregando(bool valor) {
    _estaCarregando = valor;
    notifyListeners();
  }

  /// Define a mensagem de erro caso o carregamento assíncrono falhe.
  void definirMensagemErroCarregamento(String? mensagem) {
    _mensagemErroCarregamento = mensagem;
    notifyListeners();
  }

  /// Alterna a seleção de um [item]:
  /// - No modo [ModoInteracaoPainel.unica], substitui qualquer seleção anterior.
  /// - No modo [ModoInteracaoPainel.multipla], adiciona ou remove o item do
  ///   conjunto de selecionados.
  void alternarSelecaoItem(T item) {
    if (_modoSelecao == ModoInteracaoPainel.semSelecao) {
      return;
    }
    if (_modoSelecao == ModoInteracaoPainel.unica) {
      _itensSelecionados.clear();
      _itensSelecionados.add(item);
    } else {
      if (itemEstaSelecionado(item)) {
        _itensSelecionados.removeWhere(
          (selecionado) => _mesmoItem(selecionado, item),
        );
      } else {
        _itensSelecionados.add(item);
      }
    }
    notifyListeners();
  }

  /// Remove todos os itens atualmente selecionados.
  void limparSelecao() {
    _itensSelecionados.clear();
    notifyListeners();
  }

  /// Recalcula [_itensFiltrados] aplicando o algoritmo de similaridade
  /// de texto sobre [_itensCompletos] em relação ao [_termoPesquisa] atual,
  /// ordenando do item mais relevante para o menos relevante.
  void _recalcularItensFiltrados() {
    if (_termoPesquisa.trim().isEmpty) {
      _itensFiltrados = List<T>.from(_itensCompletos);
      return;
    }

    final itensComPontuacao = _itensCompletos.map((item) {
      final pontuacao = SimilaridadeTexto.calcularPontuacaoRelevancia(
        textoItem: _obterTextoPesquisa(item),
        textoPesquisa: _termoPesquisa,
      );
      return _ItemComPontuacao<T>(item: item, pontuacao: pontuacao);
    }).where((itemComPontuacao) {
      return itemComPontuacao.pontuacao >= _pontuacaoMinimaRelevancia;
    }).toList();

    itensComPontuacao.sort(
      (a, b) => b.pontuacao.compareTo(a.pontuacao),
    );

    _itensFiltrados = itensComPontuacao
        .map((itemComPontuacao) => itemComPontuacao.item)
        .toList();
  }

  int _indiceDoItem(T item) {
    return _itensCompletos
        .indexWhere((existente) => _mesmoItem(existente, item));
  }

  bool _mesmoItem(T primeiro, T segundo) {
    return _obterIdentificador(primeiro) == _obterIdentificador(segundo);
  }

  void _removerSelecoesInexistentes() {
    _itensSelecionados.removeWhere(
      (selecionado) => !_itensCompletos.any(
        (item) => _mesmoItem(item, selecionado),
      ),
    );
  }
}

/// Classe auxiliar privada usada apenas durante o cálculo de ordenação
/// por relevância, associando cada item à sua pontuação calculada.
class _ItemComPontuacao<T> {
  const _ItemComPontuacao({required this.item, required this.pontuacao});

  final T item;
  final double pontuacao;
}

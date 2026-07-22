import '../../../core/constants/enums/prioridade.dart';

enum SituacaoItem { todos, pendentes, marcados }

class FiltroItens {
  final SituacaoItem situacao;
  final int? idCategoria;
  final Prioridade? prioridade;
  final bool? possuiPreco;

  const FiltroItens({
    this.situacao = SituacaoItem.todos,
    this.idCategoria,
    this.prioridade,
    this.possuiPreco,
  });

  bool get ativo =>
      situacao != SituacaoItem.todos ||
      idCategoria != null ||
      prioridade != null ||
      possuiPreco != null;

  FiltroItens copyWith({
    SituacaoItem? situacao,
    int? idCategoria,
    bool limparCategoria = false,
    Prioridade? prioridade,
    bool limparPrioridade = false,
    bool? possuiPreco,
    bool limparPossuiPreco = false,
  }) {
    return FiltroItens(
      situacao: situacao ?? this.situacao,
      idCategoria: limparCategoria ? null : (idCategoria ?? this.idCategoria),
      prioridade: limparPrioridade ? null : (prioridade ?? this.prioridade),
      possuiPreco: limparPossuiPreco ? null : (possuiPreco ?? this.possuiPreco),
    );
  }
}

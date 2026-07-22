import '../../../core/constants/enums/prioridade.dart';
import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/model/entidade_base.dart';

class Item extends EntidadeBase {
  int idLista;
  int idCategoria;
  TipoMedida tipoMedida;
  int? preco;
  int? quantidade;
  String? observacao;
  Prioridade prioridade;
  bool obtido;

  Item({
    super.id,
    required this.idLista,
    required this.idCategoria,
    required super.titulo,
    this.tipoMedida = TipoMedida.und,
    this.preco,
    this.quantidade,
    this.observacao,
    this.prioridade = Prioridade.neutra,
    this.obtido = false,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });

  /// Valor total em centavos. Para kg, [quantidade] representa gramas e
  /// [preco] representa o preço de um quilograma.
  int? get valorTotal {
    if (preco == null || quantidade == null) return null;
    return tipoMedida == TipoMedida.kg
        ? (preco! * quantidade! / 1000).round()
        : preco! * quantidade!;
  }

  Item copia({
    int? idLista,
    int? idCategoria,
    String? titulo,
    TipoMedida? tipoMedida,
    int? preco,
    int? quantidade,
    bool limparPreco = false,
    bool limparQuantidade = false,
    String? observacao,
    bool limparObservacao = false,
    Prioridade? prioridade,
    bool? obtido,
  }) {
    return Item(
      id: id,
      idLista: idLista ?? this.idLista,
      idCategoria: idCategoria ?? this.idCategoria,
      titulo: titulo ?? this.titulo,
      tipoMedida: tipoMedida ?? this.tipoMedida,
      preco: limparPreco ? null : (preco ?? this.preco),
      quantidade: limparQuantidade ? null : (quantidade ?? this.quantidade),
      observacao: limparObservacao ? null : (observacao ?? this.observacao),
      prioridade: prioridade ?? this.prioridade,
      obtido: obtido ?? this.obtido,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      excluido: excluido,
    );
  }
}

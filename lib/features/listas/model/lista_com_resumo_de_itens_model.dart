import 'lista_model.dart';

class ListaComResumoDeItens {
  final Lista lista;
  final int quantidadeItens;
  final int quantidadeItensMarcados;

  const ListaComResumoDeItens({
    required this.lista,
    this.quantidadeItens = 0,
    this.quantidadeItensMarcados = 0,
  });

  double get progresso =>
      quantidadeItens == 0 ? 0 : quantidadeItensMarcados / quantidadeItens;

  ListaComResumoDeItens copyWith({
    Lista? lista,
    int? quantidadeItens,
    int? quantidadeItensMarcados,
  }) {
    return ListaComResumoDeItens(
      lista: lista ?? this.lista,
      quantidadeItens: quantidadeItens ?? this.quantidadeItens,
      quantidadeItensMarcados:
          quantidadeItensMarcados ?? this.quantidadeItensMarcados,
    );
  }
}

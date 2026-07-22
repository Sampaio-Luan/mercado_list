import 'item_model.dart';

class ResumoFinanceiroItens {
  final int subtotal;
  final int totalMarcado;
  final bool possuiValor;

  const ResumoFinanceiroItens({
    required this.subtotal,
    required this.totalMarcado,
    required this.possuiValor,
  });

  factory ResumoFinanceiroItens.calcular(Iterable<Item> itens) {
    var subtotal = 0;
    var marcado = 0;
    var possuiValor = false;
    for (final item in itens) {
      final valor = item.valorTotal;
      if (valor == null) continue;
      possuiValor = true;
      subtotal += valor;
      if (item.obtido) marcado += valor;
    }
    return ResumoFinanceiroItens(
      subtotal: subtotal,
      totalMarcado: marcado,
      possuiValor: possuiValor,
    );
  }
}

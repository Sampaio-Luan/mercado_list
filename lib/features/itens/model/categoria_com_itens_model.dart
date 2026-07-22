import '../../categoria/model/categoria_model.dart';
import 'item_model.dart';

class CategoriaComItens {
  final Categoria categoria;
  final List<Item> itens;

  const CategoriaComItens({required this.categoria, required this.itens});

  int get quantidade => itens.length;
  int get subtotal =>
      itens.fold(0, (total, item) => total + (item.valorTotal ?? 0));
  int get totalMarcado => itens
      .where((item) => item.obtido)
      .fold(0, (total, item) => total + (item.valorTotal ?? 0));
}

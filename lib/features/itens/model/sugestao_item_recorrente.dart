import '../../categoria/model/categoria_model.dart';
import '../../itens_recorrentes/model/item_recorrente_model.dart';

class SugestaoItemRecorrente {
  final ItemRecorrente item;
  final Categoria categoria;
  final double relevancia;

  const SugestaoItemRecorrente({
    required this.item,
    required this.categoria,
    required this.relevancia,
  });
}

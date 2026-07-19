import 'package:mercado_list/features/categoria/model/categoria_model.dart';

import '../../itens_recorrentes/model/item_recorrente_model.dart';

class CategoriaComItensRecorrentes {
  final Categoria categoria;
  final List<ItemRecorrente> itensRecorrentes;

  CategoriaComItensRecorrentes({
    required this.categoria,
    required this.itensRecorrentes,
  });
}

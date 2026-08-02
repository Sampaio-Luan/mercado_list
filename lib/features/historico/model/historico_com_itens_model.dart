import 'historico_model.dart';
import 'item_historico_model.dart';

class HistoricoComItens {
  const HistoricoComItens({required this.historico, required this.itens});

  final Historico historico;
  final List<ItemHistorico> itens;

  int get valorTotal => itens.fold(0, (total, item) => total + item.valorTotal);
}

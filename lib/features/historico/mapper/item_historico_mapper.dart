import '../../../core/constants/enums/prioridade.dart';
import '../../../core/database/schema/tb_item_historico.dart';
import '../../../core/utils/data_utils.dart';
import '../model/item_historico_model.dart';

class ItemHistoricoMapper {
  const ItemHistoricoMapper();

  ItemHistorico doMapa(Map<String, Object?> mapa) {
    final indicePrioridade =
        mapa[TbItemHistorico.colunaPrioridade] as int? ?? 0;
    final prioridade =
        indicePrioridade >= 0 && indicePrioridade < Prioridade.values.length
            ? Prioridade.values[indicePrioridade]
            : Prioridade.neutra;
    return ItemHistorico(
      id: mapa[TbItemHistorico.colunaId] as int,
      idHistorico: mapa[TbItemHistorico.colunaIdHistorico] as int,
      titulo: mapa[TbItemHistorico.colunaTitulo] as String,
      tituloCategoria: mapa[TbItemHistorico.colunaTituloCategoria] as String,
      quantidade: mapa[TbItemHistorico.colunaQuantidade] as int,
      preco: mapa[TbItemHistorico.colunaPreco] as int,
      unidadeMedida: mapa[TbItemHistorico.colunaUnidadeDeMedida] as String,
      prioridade: prioridade,
      observacao: mapa[TbItemHistorico.colunaObservacao] as String?,
      dataCriacao: DataUtils.daPersistencia(
        mapa[TbItemHistorico.colunaDataCriacao] as String,
      ),
      dataAlteracao: DataUtils.daPersistencia(
        mapa[TbItemHistorico.colunaDataAlteracao] as String,
      ),
      excluido: mapa[TbItemHistorico.colunaExcluido] == 1,
    );
  }
}

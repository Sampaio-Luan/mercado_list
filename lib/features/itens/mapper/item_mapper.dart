import '../../../core/constants/enums/prioridade.dart';
import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/contracts/contrato_mapper.dart';
import '../../../core/database/schema/tb_item.dart';
import '../../../core/utils/data_utils.dart';
import '../model/item_model.dart';

class ItemMapper implements ContratoMapper<Item> {
  @override
  Item daNuvem(Map<String, dynamic> map) => throw UnimplementedError();

  @override
  Item doMapa(Map<String, dynamic> map) {
    return Item(
      id: map[TbItem.colunaId] as int,
      idLista: map[TbItem.colunaIdLista] as int,
      idCategoria: map[TbItem.colunaIdCategoria] as int,
      titulo: map[TbItem.colunaTitulo] as String,
      tipoMedida: TipoMedida.obterPorRotulo(
        rotulo: (map[TbItem.colunaUnidadeMedida] as String?) ?? 'und',
      ),
      preco: map[TbItem.colunaPreco] as int?,
      quantidade: map[TbItem.colunaQuantidade] as int?,
      observacao: map[TbItem.colunaObservacao] as String?,
      prioridade: Prioridade.obterPorRotulo(
        rotulo: map[TbItem.colunaPrioridade] as int,
      ),
      obtido: map[TbItem.colunaObtido] == 1,
      dataCriacao: DataUtils.daPersistencia(
        map[TbItem.colunaDataCriacao] as String,
      ),
      dataAlteracao: DataUtils.daPersistencia(
        map[TbItem.colunaDataAlteracao] as String,
      ),
      excluido: map[TbItem.colunaExcluido] == 1,
    );
  }

  @override
  Map<String, dynamic> paraMapa(Item objeto) {
    return {
      if (objeto.id != null) TbItem.colunaId: objeto.id,
      TbItem.colunaIdLista: objeto.idLista,
      TbItem.colunaIdCategoria: objeto.idCategoria,
      TbItem.colunaTitulo: objeto.titulo,
      TbItem.colunaUnidadeMedida:
          TipoMedida.obterRotulo(tipo: objeto.tipoMedida),
      TbItem.colunaPreco: objeto.preco,
      TbItem.colunaQuantidade: objeto.quantidade,
      TbItem.colunaObservacao: objeto.observacao,
      TbItem.colunaPrioridade:
          Prioridade.obterRotulo(prioridade: objeto.prioridade),
      TbItem.colunaObtido: objeto.obtido ? 1 : 0,
      if (objeto.dataCriacao != null)
        TbItem.colunaDataCriacao:
            DataUtils.paraPersistencia(objeto.dataCriacao!),
      if (objeto.dataAlteracao != null)
        TbItem.colunaDataAlteracao:
            DataUtils.paraPersistencia(objeto.dataAlteracao!),
      TbItem.colunaExcluido: objeto.excluido ? 1 : 0,
    };
  }

  @override
  Map<String, dynamic> paraNuvem(Item objeto) => {};
}

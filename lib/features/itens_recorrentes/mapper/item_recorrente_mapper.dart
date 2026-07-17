import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/contracts/contrato_mapper.dart';
import '../../../core/database/schema/tb_item_recorrente.dart';
import '../../../core/utils/data_utils.dart';
import '../model/item_recorrente_model.dart';

class ItemRecorrenteMapper implements ContratoMapper<ItemRecorrente> {
  @override
  ItemRecorrente daNuvem(Map<String, dynamic> map) {
    return ItemRecorrente.padrao(idCategoria: 1);
  }

  @override
  ItemRecorrente doMapa(Map<String, dynamic> map) {
    return ItemRecorrente(
      id: map[TbItemRecorrente.colunaId],
      idCategoria: map[TbItemRecorrente.colunaIdCategoria],
      titulo: map[TbItemRecorrente.colunaTitulo],
      tipoMedida: TipoMedida.obterPorRotulo(
        rotulo: map[TbItemRecorrente.colunaTipoMedida],
      ),
      dataCriacao: DataUtils.strParaData(
        strData: map[TbItemRecorrente.colunaDataCriacao],
      ),
      dataAlteracao: DataUtils.strParaData(
        strData: map[TbItemRecorrente.colunaDataAlteracao],
      ),
      estaExcluido: map[TbItemRecorrente.colunaEstaExcluido] == 0
          ? false
          : true,
    );
  }

  @override
  Map<String, dynamic> paraMapa(ItemRecorrente objeto) {
    Map<String, dynamic> map = {
      TbItemRecorrente.colunaId: objeto.id,
      TbItemRecorrente.colunaIdCategoria: objeto.idCategoria,
      TbItemRecorrente.colunaTitulo: objeto.titulo,
      TbItemRecorrente.colunaTipoMedida: TipoMedida.obterRotulo(
        tipo: objeto.tipoMedida,
      ),
      if (objeto.dataCriacao != null)
        TbItemRecorrente.colunaDataCriacao: objeto.dataCriacao!
            .toIso8601String(),
      if (objeto.dataAlteracao != null)
        TbItemRecorrente.colunaDataAlteracao: objeto.dataAlteracao!
            .toIso8601String(),
      TbItemRecorrente.colunaEstaExcluido: objeto.estaExcluido ? 1 : 0,
    };
    return map;
  }

  @override
  Map<String, dynamic> paraNuvem(ItemRecorrente objeto) {
    return {};
  }
}

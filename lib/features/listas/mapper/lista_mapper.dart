import '../../../core/constants/enums/cor.dart';
import '../../../core/contracts/contrato_mapper.dart';
import '../../../core/database/schema/tb_lista.dart';
import '../../../core/utils/data_utils.dart';
import '../model/lista_model.dart';

class ListaMapper implements ContratoMapper<Lista> {
  @override
  Lista daNuvem(Map<String, dynamic> map) => Lista.padrao();

  @override
  Lista doMapa(Map<String, dynamic> map) {
    return Lista(
      id: map[TbLista.colunaId] as int,
      titulo: map[TbLista.colunaTitulo] as String,
      cor: Cor.obterCor(
        cor: Cor.obterPorRotulo(rotulo: map[TbLista.colunaCor] as String),
      ),
      orcamento: map[TbLista.colunaOrcamento] as int?,
      ordem: map[TbLista.colunaOrdem] as int,
      fixada: map[TbLista.colunaFixada] == 1,
      descricao: map[TbLista.colunaDescricao] as String?,
      dataCriacao: DataUtils.daPersistencia(
        map[TbLista.colunaDataCriacao] as String,
      ),
      dataAlteracao: DataUtils.daPersistencia(
        map[TbLista.colunaDataAlteracao] as String,
      ),
      excluido: map[TbLista.colunaExcluido] == 1,
    );
  }

  @override
  Map<String, dynamic> paraMapa(Lista objeto) {
    return {
      if (objeto.id != null) TbLista.colunaId: objeto.id,
      TbLista.colunaTitulo: objeto.titulo,
      TbLista.colunaCor: Cor.obterPorColor(color: objeto.cor).name,
      TbLista.colunaOrcamento: objeto.orcamento,
      TbLista.colunaOrdem: objeto.ordem,
      TbLista.colunaFixada: objeto.fixada ? 1 : 0,
      TbLista.colunaDescricao: objeto.descricao,
      if (objeto.dataCriacao != null)
        TbLista.colunaDataCriacao:
            DataUtils.paraPersistencia(objeto.dataCriacao!),
      if (objeto.dataAlteracao != null)
        TbLista.colunaDataAlteracao:
            DataUtils.paraPersistencia(objeto.dataAlteracao!),
      TbLista.colunaExcluido: objeto.excluido ? 1 : 0,
    };
  }

  @override
  Map<String, dynamic> paraNuvem(Lista objeto) => {};
}

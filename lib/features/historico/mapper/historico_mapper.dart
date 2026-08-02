import '../../../core/constants/enums/cor.dart';
import '../../../core/database/schema/tb_historico.dart';
import '../../../core/utils/data_utils.dart';
import '../model/historico_model.dart';

class HistoricoMapper {
  const HistoricoMapper();

  Historico doMapa(Map<String, Object?> mapa) {
    final rotuloCor = mapa[TbHistorico.colunaCor] as String? ?? Cor.indigo.name;
    final cor =
        Cor.values.where((valor) => valor.name == rotuloCor).firstOrNull ??
            Cor.indigo;
    return Historico(
      id: mapa[TbHistorico.colunaId] as int,
      titulo: mapa[TbHistorico.colunaTitulo] as String,
      descricao: mapa[TbHistorico.colunaDescricao] as String?,
      dataCompra: DataUtils.daPersistencia(
        mapa[TbHistorico.colunaDataCompra] as String,
      ),
      cor: Cor.obterCor(cor: cor),
      orcamento: mapa[TbHistorico.colunaOrcamento] as int?,
      dataCriacao: DataUtils.daPersistencia(
        mapa[TbHistorico.colunaDataCriacao] as String,
      ),
      dataAlteracao: DataUtils.daPersistencia(
        mapa[TbHistorico.colunaDataAlteracao] as String,
      ),
      excluido: mapa[TbHistorico.colunaExcluido] == 1,
    );
  }

  Map<String, Object?> paraMapa(Historico historico) => {
        if (historico.id != null) TbHistorico.colunaId: historico.id,
        TbHistorico.colunaTitulo: historico.titulo,
        TbHistorico.colunaDescricao: historico.descricao,
        TbHistorico.colunaDataCompra:
            DataUtils.paraPersistencia(historico.dataCompra),
        TbHistorico.colunaCor: Cor.obterPorColor(color: historico.cor).name,
        TbHistorico.colunaOrcamento: historico.orcamento,
        if (historico.dataCriacao != null)
          TbHistorico.colunaDataCriacao:
              DataUtils.paraPersistencia(historico.dataCriacao!),
        if (historico.dataAlteracao != null)
          TbHistorico.colunaDataAlteracao:
              DataUtils.paraPersistencia(historico.dataAlteracao!),
        TbHistorico.colunaExcluido: historico.excluido ? 1 : 0,
      };
}

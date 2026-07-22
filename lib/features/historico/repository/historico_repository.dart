import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_historico.dart';
import '../../../core/database/schema/tb_item_historico.dart';
import '../../../core/utils/data_utils.dart';
import '../../itens/model/item_model.dart';
import '../../listas/model/lista_model.dart';
import '../model/historico_model.dart';

class HistoricoRepository {
  final BancoLocal bancoLocal;

  HistoricoRepository(this.bancoLocal);

  Future<Historico> salvarCompra({
    required Lista lista,
    required List<Item> itens,
    required Map<int, String> titulosCategorias,
  }) {
    return bancoLocal.executar((executor) async {
      final agora = DataUtils.agoraUtc();
      final id = await executor.insert(TbHistorico.nomeTabela, {
        TbHistorico.colunaTitulo: lista.titulo,
        TbHistorico.colunaDescricao: lista.descricao,
        TbHistorico.colunaDataCompra: DataUtils.paraPersistencia(agora),
        TbHistorico.colunaDataCriacao: DataUtils.paraPersistencia(agora),
        TbHistorico.colunaDataAlteracao: DataUtils.paraPersistencia(agora),
        TbHistorico.colunaExcluido: 0,
      });
      final batch = executor.batch();
      for (final item in itens) {
        batch.insert(TbItemHistorico.nomeTabela, {
          TbItemHistorico.colunaIdHistorico: id,
          TbItemHistorico.colunaTitulo: item.titulo,
          TbItemHistorico.colunaTituloCategoria:
              titulosCategorias[item.idCategoria] ?? 'Sem categoria',
          TbItemHistorico.colunaQuantidade:
              item.quantidade ?? (item.tipoMedida == TipoMedida.kg ? 1000 : 1),
          TbItemHistorico.colunaPreco: item.preco ?? 0,
          TbItemHistorico.colunaUnidadeDeMedida:
              TipoMedida.obterRotulo(tipo: item.tipoMedida),
          TbItemHistorico.colunaDataCriacao: DataUtils.paraPersistencia(agora),
          TbItemHistorico.colunaDataAlteracao:
              DataUtils.paraPersistencia(agora),
          TbItemHistorico.colunaExcluido: 0,
        });
      }
      return Historico(
        id: id,
        titulo: lista.titulo,
        descricao: lista.descricao,
        dataCompra: agora,
        dataCriacao: agora,
        dataAlteracao: agora,
      );
    });
  }
}

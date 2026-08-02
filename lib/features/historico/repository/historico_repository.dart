import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_historico.dart';
import '../../../core/database/schema/tb_item_historico.dart';
import '../../../core/utils/data_utils.dart';
import '../../itens/model/item_model.dart';
import '../../listas/model/lista_model.dart';
import '../model/historico_model.dart';
import '../model/historico_com_itens_model.dart';
import '../model/item_historico_model.dart';

class HistoricoRepository {
  final BancoLocal bancoLocal;

  HistoricoRepository(this.bancoLocal);

  Future<List<HistoricoComItens>> recuperarTodosComItens() {
    return bancoLocal.executar((executor) async {
      final historicosMap = await executor.query(
        TbHistorico.nomeTabela,
        where: '${TbHistorico.colunaExcluido} = ?',
        whereArgs: [0],
        orderBy: '${TbHistorico.colunaDataCompra} DESC',
      );
      if (historicosMap.isEmpty) return const [];

      final ids = historicosMap
          .map((linha) => linha[TbHistorico.colunaId] as int)
          .toList(growable: false);
      final placeholders = List.filled(ids.length, '?').join(', ');
      final itensMap = await executor.query(
        TbItemHistorico.nomeTabela,
        where: '${TbItemHistorico.colunaExcluido} = ? AND '
            '${TbItemHistorico.colunaIdHistorico} IN ($placeholders)',
        whereArgs: [0, ...ids],
        orderBy: TbItemHistorico.colunaId,
      );
      final itensPorHistorico = <int, List<ItemHistorico>>{};
      for (final linha in itensMap) {
        final item = _mapearItem(linha);
        itensPorHistorico.putIfAbsent(item.idHistorico, () => []).add(item);
      }
      return historicosMap.map((linha) {
        final historico = _mapearHistorico(linha);
        return HistoricoComItens(
          historico: historico,
          itens: List.unmodifiable(itensPorHistorico[historico.id] ?? const []),
        );
      }).toList(growable: false);
    });
  }

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

  Historico _mapearHistorico(Map<String, Object?> linha) {
    return Historico(
      id: linha[TbHistorico.colunaId] as int,
      titulo: linha[TbHistorico.colunaTitulo] as String,
      descricao: linha[TbHistorico.colunaDescricao] as String?,
      dataCompra: DataUtils.daPersistencia(
        linha[TbHistorico.colunaDataCompra] as String,
      ),
      dataCriacao: DataUtils.daPersistencia(
        linha[TbHistorico.colunaDataCriacao] as String,
      ),
      dataAlteracao: DataUtils.daPersistencia(
        linha[TbHistorico.colunaDataAlteracao] as String,
      ),
      excluido: (linha[TbHistorico.colunaExcluido] as int) == 1,
    );
  }

  ItemHistorico _mapearItem(Map<String, Object?> linha) {
    return ItemHistorico(
      id: linha[TbItemHistorico.colunaId] as int,
      idHistorico: linha[TbItemHistorico.colunaIdHistorico] as int,
      titulo: linha[TbItemHistorico.colunaTitulo] as String,
      tituloCategoria: linha[TbItemHistorico.colunaTituloCategoria] as String,
      quantidade: linha[TbItemHistorico.colunaQuantidade] as int,
      preco: linha[TbItemHistorico.colunaPreco] as int,
      unidadeMedida: linha[TbItemHistorico.colunaUnidadeDeMedida] as String,
      dataCriacao: DataUtils.daPersistencia(
        linha[TbItemHistorico.colunaDataCriacao] as String,
      ),
      dataAlteracao: DataUtils.daPersistencia(
        linha[TbItemHistorico.colunaDataAlteracao] as String,
      ),
      excluido: (linha[TbItemHistorico.colunaExcluido] as int) == 1,
    );
  }
}

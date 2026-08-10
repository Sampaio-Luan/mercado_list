import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/constants/enums/cor.dart';
import '../../../core/database/banco_local.dart';
import '../../../core/database/schema/tb_historico.dart';
import '../../../core/database/schema/tb_item_historico.dart';
import '../../../core/utils/data_utils.dart';
import '../../itens/model/item_model.dart';
import '../model/historico_model.dart';
import '../model/historico_com_itens_model.dart';
import '../model/item_historico_model.dart';
import '../mapper/historico_mapper.dart';
import '../mapper/item_historico_mapper.dart';

typedef AoSalvarItemHistorico = Future<void> Function(
  int indice,
  int total,
  String titulo,
);

abstract interface class HistoricoRepositoryContract {
  Future<List<HistoricoComItens>> recuperarTodosComItens();

  Future<Historico> salvarCompra({
    required Historico historico,
    required List<Item> itens,
    required Map<int, String> titulosCategorias,
    AoSalvarItemHistorico? aoSalvarItem,
  });

  Future<Historico> editar(Historico historico);

  Future<ItemHistorico> editarItem(ItemHistorico item);

  Future<void> excluir(Historico historico);
}

class HistoricoRepository implements HistoricoRepositoryContract {
  final BancoLocal bancoLocal;
  final HistoricoMapper historicoMapper;
  final ItemHistoricoMapper itemHistoricoMapper;

  HistoricoRepository(
    this.bancoLocal, {
    this.historicoMapper = const HistoricoMapper(),
    this.itemHistoricoMapper = const ItemHistoricoMapper(),
  });

  @override
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
        final item = itemHistoricoMapper.doMapa(linha);
        itensPorHistorico.putIfAbsent(item.idHistorico, () => []).add(item);
      }
      return historicosMap.map((linha) {
        final historico = historicoMapper.doMapa(linha);
        return HistoricoComItens(
          historico: historico,
          itens: List.unmodifiable(itensPorHistorico[historico.id] ?? const []),
        );
      }).toList(growable: false);
    });
  }

  @override
  Future<Historico> salvarCompra({
    required Historico historico,
    required List<Item> itens,
    required Map<int, String> titulosCategorias,
    AoSalvarItemHistorico? aoSalvarItem,
  }) {
    return bancoLocal.executar((executor) async {
      final agora = DataUtils.agoraUtc();
      final id = await executor.insert(TbHistorico.nomeTabela, {
        TbHistorico.colunaTitulo: historico.titulo,
        TbHistorico.colunaDescricao: historico.descricao,
        TbHistorico.colunaLoja: historico.loja,
        TbHistorico.colunaCor: Cor.obterPorColor(color: historico.cor).name,
        TbHistorico.colunaOrcamento: historico.orcamento,
        TbHistorico.colunaDataCompra:
            DataUtils.paraPersistencia(historico.dataCompra),
        TbHistorico.colunaDataCriacao: DataUtils.paraPersistencia(agora),
        TbHistorico.colunaDataAlteracao: DataUtils.paraPersistencia(agora),
        TbHistorico.colunaExcluido: 0,
      });
      for (var indice = 0; indice < itens.length; indice++) {
        final item = itens[indice];
        final preco = item.preco;
        if (!item.obtido || preco == null) {
          throw ArgumentError(
            'O histórico aceita somente itens marcados e com preço.',
          );
        }
        await executor.insert(TbItemHistorico.nomeTabela, {
          TbItemHistorico.colunaIdHistorico: id,
          TbItemHistorico.colunaTitulo: item.titulo,
          TbItemHistorico.colunaTituloCategoria:
              titulosCategorias[item.idCategoria] ?? 'Sem categoria',
          TbItemHistorico.colunaQuantidade:
              item.quantidade ?? (item.tipoMedida == TipoMedida.kg ? 1000 : 1),
          TbItemHistorico.colunaPreco: preco,
          TbItemHistorico.colunaUnidadeDeMedida:
              TipoMedida.obterRotulo(tipo: item.tipoMedida),
          TbItemHistorico.colunaPrioridade: item.prioridade.index,
          TbItemHistorico.colunaObservacao: item.observacao,
          TbItemHistorico.colunaDataCriacao: DataUtils.paraPersistencia(agora),
          TbItemHistorico.colunaDataAlteracao:
              DataUtils.paraPersistencia(agora),
          TbItemHistorico.colunaExcluido: 0,
        });
        await aoSalvarItem?.call(indice + 1, itens.length, item.titulo);
      }
      return Historico(
        id: id,
        titulo: historico.titulo,
        descricao: historico.descricao,
        loja: historico.loja,
        dataCompra: historico.dataCompra,
        cor: historico.cor,
        orcamento: historico.orcamento,
        dataCriacao: agora,
        dataAlteracao: agora,
      );
    });
  }

  @override
  Future<Historico> editar(Historico historico) {
    return bancoLocal.executar((executor) async {
      final id = historico.id;
      if (id == null) throw StateError('O histórico precisa estar persistido.');
      final editado = historico.copia()..dataAlteracao = DataUtils.agoraUtc();
      final mapa = historicoMapper.paraMapa(editado)
        ..remove(TbHistorico.colunaId)
        ..remove(TbHistorico.colunaDataCriacao);
      final linhas = await executor.update(
        TbHistorico.nomeTabela,
        mapa,
        where: '${TbHistorico.colunaId} = ? AND '
            '${TbHistorico.colunaExcluido} = 0',
        whereArgs: [id],
      );
      if (linhas == 0) throw StateError('Histórico não encontrado.');
      return editado;
    });
  }

  @override
  Future<ItemHistorico> editarItem(ItemHistorico item) {
    return bancoLocal.executar((executor) async {
      final id = item.id;
      if (id == null) throw StateError('O item precisa estar persistido.');
      final agora = DataUtils.agoraUtc();
      final linhas = await executor.update(
        TbItemHistorico.nomeTabela,
        {
          TbItemHistorico.colunaTitulo: item.titulo,
          TbItemHistorico.colunaQuantidade: item.quantidade,
          TbItemHistorico.colunaPreco: item.preco,
          TbItemHistorico.colunaDataAlteracao:
              DataUtils.paraPersistencia(agora),
        },
        where: '${TbItemHistorico.colunaId} = ? AND '
            '${TbItemHistorico.colunaIdHistorico} = ? AND '
            '${TbItemHistorico.colunaExcluido} = 0',
        whereArgs: [id, item.idHistorico],
      );
      if (linhas == 0) throw StateError('Item do histórico não encontrado.');
      return item.copia()..dataAlteracao = agora;
    });
  }

  @override
  Future<void> excluir(Historico historico) {
    return bancoLocal.executar((executor) async {
      final id = historico.id;
      if (id == null) throw StateError('O histórico precisa estar persistido.');
      final linhas = await executor.update(
        TbHistorico.nomeTabela,
        {
          TbHistorico.colunaExcluido: 1,
          TbHistorico.colunaDataAlteracao:
              DataUtils.paraPersistencia(DataUtils.agoraUtc()),
        },
        where: '${TbHistorico.colunaId} = ? AND '
            '${TbHistorico.colunaExcluido} = 0',
        whereArgs: [id],
      );
      if (linhas == 0) throw StateError('Histórico não encontrado.');
    });
  }
}

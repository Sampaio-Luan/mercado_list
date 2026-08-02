import '../../contracts/contrato_tb_esquema.dart';
import 'colunas_entidade.dart';
import 'tb_historico.dart';

class TbItemHistorico implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_item_historico';

  static const String colunaId = 'id_item_historico';
  static const String colunaIdHistorico = 'id_historico';
  static const String colunaTitulo = ColunasEntidade.titulo;
  static const String colunaTituloCategoria = 'titulo_categoria';
  static const String colunaQuantidade = 'quantidade';
  static const String colunaPreco = 'preco';
  static const String colunaUnidadeDeMedida = 'unidade_medida';
  static const String colunaPrioridade = 'prioridade';
  static const String colunaObservacao = 'observacao';
  static const String colunaDataCriacao = ColunasEntidade.dataCriacao;
  static const String colunaDataAlteracao = ColunasEntidade.dataAlteracao;
  static const String colunaExcluido = ColunasEntidade.excluido;

  static String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaIdHistorico INTEGER NOT NULL,
      $colunaTitulo TEXT NOT NULL,
      $colunaTituloCategoria TEXT NOT NULL,
      $colunaQuantidade INTEGER NOT NULL,
      $colunaPreco INTEGER NOT NULL,
      $colunaUnidadeDeMedida TEXT NOT NULL,
      $colunaPrioridade INTEGER NOT NULL DEFAULT 0,
      $colunaObservacao TEXT,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaExcluido INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colunaIdHistorico) REFERENCES ${TbHistorico.nomeTabela}(${TbHistorico.colunaId}) ON UPDATE CASCADE ON DELETE CASCADE
    )
  ''';

  static const String criarIndiceHistorico = '''
    CREATE INDEX idx_item_historico_historico
    ON $nomeTabela ($colunaIdHistorico, $colunaExcluido)
  ''';
}

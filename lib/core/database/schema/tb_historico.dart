import '../../contracts/contrato_tb_esquema.dart';
import 'colunas_entidade.dart';

class TbHistorico implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_historico';

  static const String colunaId = 'id_historico';
  static const String colunaTitulo = ColunasEntidade.titulo;
  static const String colunaDescricao = 'descricao';
  static const String colunaCor = 'cor';
  static const String colunaOrcamento = 'orcamento';
  static const String colunaDataCompra = 'dt_compra';
  static const String colunaDataCriacao = ColunasEntidade.dataCriacao;
  static const String colunaDataAlteracao = ColunasEntidade.dataAlteracao;
  static const String colunaExcluido = ColunasEntidade.excluido;

  static String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaDescricao TEXT,
      $colunaCor TEXT NOT NULL DEFAULT 'indigo',
      $colunaOrcamento INTEGER,
      $colunaDataCompra TIMESTAMP NOT NULL,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaExcluido INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String criarIndiceData = '''
    CREATE INDEX idx_historico_data
    ON $nomeTabela ($colunaExcluido, $colunaDataCompra DESC)
  ''';
}

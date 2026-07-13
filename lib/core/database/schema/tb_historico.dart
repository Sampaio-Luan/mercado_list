import 'contrato_tb_esquema.dart';

class TbHistorico implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_historico';

  static const String colunaId = 'id_historico';
  static const String colunaTitulo = 'titulo';
  static const String colunaDescricao = 'descricao';
  static const String colunaDataCompra = 'dt_compra';
  static const String colunaDataCriacao = 'dt_criacao';
  static const String colunaDataAlteracao = 'dt_alteracao';
  static const String colunaEstaExcluido = 'esta_excluido';


  static String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaDescricao TEXT,
      $colunaDataCompra TIMESTAMP NOT NULL,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaEstaExcluido INTEGER NOT NULL DEFAULT 0
    )
  ''';
}

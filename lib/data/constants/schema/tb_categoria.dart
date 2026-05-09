import 'contrato_tb_esquema.dart';

class TbCategoria implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_categoria';

  static const String colunaId = 'id_categoria';
  static const String colunaTitulo = 'titulo';
  static const String colunaCor = 'cor';
  static const String colunaOrdem = 'ordem';
  static const String colunaDescricao = 'descricao';
  static const String colunaDataCriacao = 'dt_criacao';
  static const String colunaDataAlteracao = 'dt_alteracao';
  static const String colunaEstaExcluido = 'esta_excluido';

  @override
  String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaCor TEXT NOT NULL,
      $colunaOrdem INTEGER NOT NULL,
      $colunaDescricao TEXT,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaEstaExcluido INTEGER NOT NULL DEFAULT 0
    )
  ''';
}

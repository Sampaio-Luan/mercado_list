import 'contrato_tb_esquema.dart';

class TbLista implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_lista';

  static const String colunaId = 'id_lista';
  static const String colunaTitulo = 'titulo';
  static const String colunaDescricao = 'descricao';
  static const String colunaDataCriacao = 'dt_criacao';
  static const String colunaDataAlteracao = 'dt_alteracao';
  static const String colunaEstaExcluido = 'esta_excluido';

  static const String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaDescricao TEXT,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaEstaExcluido INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String recuperarTodos = '''
    SELECT *
    FROM $nomeTabela
    WHERE $colunaEstaExcluido = 0 
 ''';
}

import '../../contracts/contrato_tb_esquema.dart';
import 'colunas_entidade.dart';

class TbLista implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_lista';

  static const String colunaId = 'id_lista';
  static const String colunaTitulo = ColunasEntidade.titulo;
  static const String colunaDescricao = 'descricao';
  static const String colunaDataCriacao = ColunasEntidade.dataCriacao;
  static const String colunaDataAlteracao = ColunasEntidade.dataAlteracao;
  static const String colunaExcluido = ColunasEntidade.excluido;

  static const String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaDescricao TEXT,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaExcluido INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String recuperarTodos = '''
    SELECT *
    FROM $nomeTabela
    WHERE $colunaExcluido = 0
 ''';
}

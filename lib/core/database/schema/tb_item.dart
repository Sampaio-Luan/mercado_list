import '../../contracts/contrato_tb_esquema.dart';
import 'colunas_entidade.dart';
import 'tb_categoria.dart';
import 'tb_lista.dart';

class TbItem implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_item';

  static const String colunaId = 'id_item';
  static const String colunaIdLista = 'id_lista';
  static const String colunaIdCategoria = 'id_categoria';
  static const String colunaTitulo = ColunasEntidade.titulo;
  static const String colunaUnidadeMedida = 'unidade_medida';
  static const String colunaPreco = 'preco';
  static const String colunaQuantidade = 'quantidade';
  static const String colunaObservacao = 'observacao';
  static const String colunaPrioridade = 'prioridade';
  static const String colunaObtido = 'obtido';
  static const String colunaDataCriacao = ColunasEntidade.dataCriacao;
  static const String colunaDataAlteracao = ColunasEntidade.dataAlteracao;
  static const String colunaExcluido = ColunasEntidade.excluido;

  static const String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaIdLista INTEGER NOT NULL,
      $colunaIdCategoria INTEGER NOT NULL,
      $colunaTitulo TEXT NOT NULL,
      $colunaUnidadeMedida TEXT,
      $colunaPreco INTEGER,
      $colunaQuantidade INTEGER,
      $colunaObservacao TEXT,
      $colunaPrioridade INTEGER NOT NULL DEFAULT 0,
      $colunaObtido INTEGER NOT NULL DEFAULT 0,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaExcluido INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colunaIdLista) REFERENCES ${TbLista.nomeTabela}(${TbLista.colunaId}) ON UPDATE CASCADE ON DELETE CASCADE,
      FOREIGN KEY ($colunaIdCategoria) REFERENCES ${TbCategoria.nomeTabela}(${TbCategoria.colunaId}) ON UPDATE CASCADE ON DELETE CASCADE
  )
  ''';
}

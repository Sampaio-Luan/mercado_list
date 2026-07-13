import 'contrato_tb_esquema.dart';
import 'tb_historico.dart';

class TbItemHistorico implements ContratoTbEsquema {
  static const String nomeTabela = 'tb_item_historico';

  static const String colunaId = 'id_item_historico';
  static const String colunaIdHistorico = 'id_historico';
  static const String colunaTitulo = 'titulo';
  static const String colunaTituloCategoria = 'titulo_categoria';
  static const String colunaQuantidade = 'quantidade';
  static const String colunaPreco = 'preco';
  static const String colunaUnidadeDeMedida = 'unidade_medida';
  static const String colunaDataCriacao = 'data_criacao';
  static const String colunaDataAlteracao = 'data_alteracao';
  static const String colunaEstaExcluido = 'esta_excluido';


 static String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaIdHistorico INTEGER NOT NULL,
      $colunaTitulo TEXT NOT NULL,
      $colunaTituloCategoria TEXT NOT NULL,
      $colunaQuantidade INTEGER NOT NULL,
      $colunaPreco INTEGER NOT NULL,
      $colunaUnidadeDeMedida TEXT NOT NULL,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaEstaExcluido INTEGER NOT NULL,
      FOREIGN KEY ($colunaIdHistorico) REFERENCES ${TbHistorico.nomeTabela}(${TbHistorico.colunaId}) ON UPDATE CASCADE ON DELETE CASCADE
    )
  ''';


}

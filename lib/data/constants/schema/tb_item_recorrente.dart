import 'contrato_tb_esquema.dart';
import 'tb_categoria.dart';

class TbItemRecorrente implements ContratoTbEsquema{
  static const String nomeTabela = 'tb_item_recorrente';

  static const String colunaId = 'id_item_recorrente';
  static const String colunaIdCategoria = 'id_categoria';
  static const String colunaTitulo = 'titulo';
  static const String colunaDataCriacao = 'dt_criacao';
  static const String colunaDataAlteracao = 'dt_alteracao';
  static const String colunaEstaExcluido = 'esta_excluido';

  @override
  String  criarTabela =  '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaIdCategoria INTEGER NOT NULL,
      $colunaTitulo TEXT NOT NULL,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaEstaExcluido INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($colunaIdCategoria) REFERENCES ${TbCategoria.nomeTabela}(${TbCategoria.colunaId}) ON UPDATE CASCADE ON DELETE CASCADE
    )
  ''';
}
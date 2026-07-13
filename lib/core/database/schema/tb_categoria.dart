import '../../contracts/contrato_tb_esquema.dart';

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


  static const String criarTabela = '''
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

  static const String inserirCategorias = '''
    INSERT INTO $nomeTabela ($colunaTitulo, $colunaCor, $colunaOrdem)
    VALUES
      ('Higiene Pessoal', 'indigo', 1),
      ('Limpeza', 'roxoEscuro', 2),
      ('Mercearia', 'roxo', 3),
      ('Hortifruti', 'rosa', 4),
      ('Frios', 'vermelho', 5),
      ('Açougue', 'laranjaEscuro', 6),
      ('Padaria', 'laranja', 7),
      ('Bebidas', 'ambar', 8),
      ('Confeitaria', 'amarelo', 9),
      ('Bazar', 'lima', 10),
      ('Petshop', 'verdeClaro', 11),
      ('Congelados', 'verde', 12),
      ('Condimentos', 'verdeAzulado', 13),
      ('Laticinios', 'ciano', 14),
      ('Peixaria', 'azulClaro', 15),
      ('Beleza', 'azul', 16),
      ('Utilidades', 'azulCinzento', 17),
      ('Outros', 'marrom', 18)
  ''';
}

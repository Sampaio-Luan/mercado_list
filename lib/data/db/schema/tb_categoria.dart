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
      ('Higiene Pessoal', 'azul', 1),
      ('Limpeza', 'verde', 2),
      ('Mercearia', 'vermelho', 3),
      ('Hortifruti', 'amarelo', 4),
      ('Frios', 'roxo', 5),
      ('Açougue', 'laranja', 6),
      ('Padaria', 'cinza', 7),
      ('Bebidas', 'azul', 8),
      ('Confeitaria', 'roxo', 9),
      ('Bazar', 'verde', 10),
      ('Petshop', 'laranja', 11),
      ('Congelados', 'amarelo', 12),
      ('Condimentos', 'cinza', 13),
      ('Laticinios', 'azul', 14),
      ('Peixaria', 'vermelho', 15),
      ('Beleza', 'verde', 16),
      ('Utilidades', 'amarelo', 17),
      ('Outros', 'preto', 18)
  ''';
}

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
  static const String colunaCategoriaPadrao = 'categoria_padrao';


  static const String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaCor TEXT NOT NULL,
      $colunaOrdem INTEGER NOT NULL,
      $colunaDescricao TEXT,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      $colunaEstaExcluido INTEGER NOT NULL DEFAULT 0,
      $colunaCategoriaPadrao INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String inserirCategorias = '''
    INSERT INTO $nomeTabela ($colunaTitulo, $colunaCor, $colunaOrdem, $colunaCategoriaPadrao)
    VALUES
      ('Higiene Pessoal', 'indigo', 1,0),
      ('Limpeza', 'roxoEscuro', 2,0),
      ('Mercearia', 'roxo', 3,0),
      ('Hortifruti', 'rosa', 4,0),
      ('Frios', 'vermelho', 5,0),
      ('Açougue', 'laranjaEscuro', 6,0),
      ('Padaria', 'laranja', 7,0),
      ('Bebidas', 'ambar', 8,0),
      ('Confeitaria', 'amarelo', 9,0),
      ('Bazar', 'lima', 10,0),
      ('Petshop', 'verdeClaro', 11,0),
      ('Congelados', 'verde', 12,0),
      ('Condimentos', 'verdeAzulado', 13,0),
      ('Laticinios', 'ciano', 14,0),
      ('Peixaria', 'azulClaro', 15,0),
      ('Beleza', 'azul', 16,0),
      ('Utilidades', 'azulCinzento', 17,0),
      ('Outros', 'marrom', 18, 1)
  ''';
}

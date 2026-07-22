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

  static const String criarIndiceLista = '''
    CREATE INDEX idx_item_lista
    ON $nomeTabela ($colunaIdLista, $colunaExcluido, $colunaObtido)
  ''';

  static const String inserirItensExemplo = '''
    INSERT INTO $nomeTabela
      ($colunaIdLista, $colunaIdCategoria, $colunaTitulo,
       $colunaUnidadeMedida, $colunaQuantidade, $colunaObservacao)
    SELECT lista.id_lista, categoria.id_categoria,
           produto.titulo, produto.medida, produto.quantidade,
           produto.observacao
    FROM tb_lista lista
    JOIN (
      SELECT 'Arroz' AS titulo, 'kg' AS medida, 5000 AS quantidade,
             'Tipo 1' AS observacao, 'Mercearia' AS categoria
      UNION ALL
      SELECT 'Leite integral', 'und', 6, NULL, 'Laticinios'
      UNION ALL
      SELECT 'Banana', 'kg', 2000, NULL, 'Hortifruti'
      UNION ALL
      SELECT 'Detergente', 'und', 2, NULL, 'Limpeza'
      UNION ALL
      SELECT 'Sabonete', 'und', 4, NULL, 'Higiene Pessoal'
    ) produto
    JOIN tb_categoria categoria
      ON categoria.titulo = produto.categoria
     AND categoria.excluido = 0
    WHERE lista.titulo = '${TbLista.tituloExemplo}'
      AND lista.descricao = '${TbLista.descricaoExemplo}'
      AND lista.excluido = 0
      AND NOT EXISTS (
        SELECT 1
        FROM $nomeTabela item_existente
        WHERE item_existente.$colunaIdLista = lista.id_lista
          AND item_existente.$colunaTitulo = produto.titulo
      )
  ''';

  /// Usado apenas pelas migrations anteriores à v9, quando kg ainda era
  /// persistido como um número inteiro de quilogramas. A v9 converte os
  /// valores inseridos por este comando para gramas.
  static const String inserirItensExemploSeAusentes = '''
    INSERT INTO $nomeTabela
      ($colunaIdLista, $colunaIdCategoria, $colunaTitulo,
       $colunaUnidadeMedida, $colunaQuantidade, $colunaObservacao)
    SELECT lista.id_lista, categoria.id_categoria,
           produto.titulo, produto.medida, produto.quantidade,
           produto.observacao
    FROM tb_lista lista
    JOIN (
      SELECT 'Arroz' AS titulo, 'kg' AS medida, 5 AS quantidade,
             'Tipo 1' AS observacao, 'Mercearia' AS categoria
      UNION ALL
      SELECT 'Leite integral', 'und', 6, NULL, 'Laticinios'
      UNION ALL
      SELECT 'Banana', 'kg', 2, NULL, 'Hortifruti'
      UNION ALL
      SELECT 'Detergente', 'und', 2, NULL, 'Limpeza'
      UNION ALL
      SELECT 'Sabonete', 'und', 4, NULL, 'Higiene Pessoal'
    ) produto
    JOIN tb_categoria categoria
      ON categoria.titulo = produto.categoria
     AND categoria.excluido = 0
    WHERE lista.titulo = '${TbLista.tituloExemplo}'
      AND lista.descricao = '${TbLista.descricaoExemplo}'
      AND lista.excluido = 0
      AND NOT EXISTS (
        SELECT 1
        FROM $nomeTabela item_existente
        WHERE item_existente.$colunaIdLista = lista.id_lista
          AND item_existente.$colunaTitulo = produto.titulo
      )
  ''';

  static const String excluirDicasAntigasDaListaExemplo = '''
    UPDATE $nomeTabela
    SET $colunaExcluido = 1,
        $colunaDataAlteracao = CURRENT_TIMESTAMP
    WHERE $colunaIdLista IN (
      SELECT lista.id_lista
      FROM tb_lista lista
      WHERE lista.titulo = '${TbLista.tituloExemplo}'
        AND lista.descricao = '${TbLista.descricaoExemplo}'
        AND lista.excluido = 0
    )
      AND $colunaTitulo IN (
        'Marque os itens conforme coloca no carrinho',
        'Salve os itens marcados no histórico',
        'Edite, copie ou exclua esta lista de exemplo'
      )
      AND $colunaExcluido = 0
  ''';
}

import '../../contracts/contrato_tb_esquema.dart';
import 'colunas_entidade.dart';

class TbLista implements ContratoTbEsquema {
  static const String tituloExemplo = 'Mensal (Exemplo)';
  static const String descricaoExemploAnterior =
      'Uma lista editável com dicas para conhecer o Mercado List.';
  static const String descricaoExemplo =
      'Marque os produtos conforme coloca no carrinho. Ao finalizar, salve '
      'os itens marcados no histórico para reutilizá-los depois. Você pode '
      'editar, copiar ou excluir esta lista.';

  static const String nomeTabela = 'tb_lista';

  static const String colunaId = 'id_lista';
  static const String colunaTitulo = ColunasEntidade.titulo;
  static const String colunaCor = 'cor';
  static const String colunaOrcamento = 'orcamento';
  static const String colunaOrdem = 'ordem';
  static const String colunaFixada = 'fixada';
  static const String colunaDescricao = 'descricao';
  static const String colunaDataCriacao = ColunasEntidade.dataCriacao;
  static const String colunaDataAlteracao = ColunasEntidade.dataAlteracao;
  static const String colunaExcluido = ColunasEntidade.excluido;

  static const String criarTabela = '''
    CREATE TABLE $nomeTabela (
      $colunaId INTEGER PRIMARY KEY AUTOINCREMENT,
      $colunaTitulo TEXT NOT NULL,
      $colunaCor TEXT NOT NULL,
      $colunaOrcamento INTEGER,
      $colunaOrdem INTEGER NOT NULL,
      $colunaFixada INTEGER NOT NULL DEFAULT 0
        CHECK ($colunaFixada IN (0, 1)),
      $colunaDescricao TEXT,
      $colunaDataCriacao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaDataAlteracao TIMESTAMP NOT NULL DEFAULT ${ColunasEntidade.dataAtualUtc},
      $colunaExcluido INTEGER NOT NULL DEFAULT 0
    )
  ''';

  static const String criarIndiceOrdenacao = '''
    CREATE INDEX idx_lista_ordenacao
    ON $nomeTabela ($colunaExcluido, $colunaFixada DESC, $colunaOrdem)
  ''';

  static const String inserirListaExemplo = '''
    INSERT INTO $nomeTabela
      ($colunaTitulo, $colunaCor, $colunaOrdem, $colunaDescricao)
    VALUES
      ('$tituloExemplo', 'indigo', 0, '$descricaoExemplo')
  ''';

  static const String inserirListaExemploSeAusente = '''
    INSERT INTO $nomeTabela
      ($colunaTitulo, $colunaCor, $colunaOrdem, $colunaDescricao)
    SELECT
      '$tituloExemplo',
      'indigo',
      (SELECT COALESCE(MAX($colunaOrdem), -1) + 1 FROM $nomeTabela),
      '$descricaoExemplo'
    WHERE NOT EXISTS (
      SELECT 1
      FROM $nomeTabela
      WHERE $colunaTitulo = '$tituloExemplo'
    )
  ''';

  static const String atualizarDescricaoListaExemplo = '''
    UPDATE $nomeTabela
    SET $colunaDescricao = '$descricaoExemplo',
        $colunaDataAlteracao = CURRENT_TIMESTAMP
    WHERE $colunaTitulo = '$tituloExemplo'
      AND $colunaDescricao = '$descricaoExemploAnterior'
      AND $colunaExcluido = 0
  ''';

  static const String recuperarTodos = '''
    SELECT *
    FROM $nomeTabela
    WHERE $colunaExcluido = 0
 ''';
}

class ColunasEntidade {
  ColunasEntidade._();

  static const String titulo = 'titulo';
  static const String dataCriacao = 'dt_criacao';
  static const String dataAlteracao = 'dt_alteracao';
  static const String excluido = 'excluido';
  static const String dataAtualUtc = "(STRFTIME('%Y-%m-%dT%H:%M:%fZ', 'NOW'))";
}

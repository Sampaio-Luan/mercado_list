class Lista{
  int? id;
  String titulo;
  String? descricao;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool estaExcluido;

// #region ======================== Construtores =========================

  Lista({
    this.id,
    required this.titulo,
    this.descricao,
    this.dataCriacao,
    this.dataAlteracao,
    this.estaExcluido = false,
  });

  static Lista padrao() {
    return Lista(
      id: null,
      titulo: '',
      descricao: null,
      dataCriacao: null,
      dataAlteracao: null,
      estaExcluido: false,
    );
  }
// #endregion ===================== End Construtores ====================

// #region ======================== Implementação ContratoModelo ========

  Lista copia() {
    return Lista(
      id: id,
      titulo: titulo,
      descricao: descricao,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      estaExcluido: estaExcluido,
    );
  }
 

// #endregion ===================== End Implementação ContratoModelo =====

// #region ======================== Setters ==================================
void setTitulo(String titulo) => this.titulo = titulo;
void setDescricao(String descricao) {
  descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
}


//#endregion ===================== End Setters ==============================
}

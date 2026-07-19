import '../../../core/model/entidade_base.dart';

class Lista extends EntidadeBase {
  String? descricao;

// #region ======================== Construtores =========================

  Lista({
    super.id,
    required super.titulo,
    this.descricao,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });

  static Lista padrao() {
    return Lista(
      id: null,
      titulo: '',
      descricao: null,
      dataCriacao: null,
      dataAlteracao: null,
      excluido: false,
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
      excluido: excluido,
    );
  }

// #endregion ===================== End Implementação ContratoModelo =====

// #region ======================== Setters ==================================
  void setDescricao(String descricao) {
    descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
  }

//#endregion ===================== End Setters ==============================
}

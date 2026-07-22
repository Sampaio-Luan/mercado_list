import 'package:flutter/material.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/model/entidade_base.dart';

class Lista extends EntidadeBase {
  Color cor;
  int? orcamento;
  int ordem;
  bool fixada;
  String? descricao;

// #region ======================== Construtores =========================

  Lista({
    super.id,
    required super.titulo,
    required this.cor,
    this.orcamento,
    required this.ordem,
    this.fixada = false,
    this.descricao,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });

  static Lista padrao() {
    return Lista(
      id: null,
      titulo: '',
      cor: Cor.obterListaCores().first,
      orcamento: null,
      ordem: 0,
      fixada: false,
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
      cor: cor,
      orcamento: orcamento,
      ordem: ordem,
      fixada: fixada,
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

  Color setCor(Cor cor) => this.cor = Cor.obterCor(cor: cor);

//#endregion ===================== End Setters ==============================
}

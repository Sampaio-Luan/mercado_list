import 'package:flutter/material.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/model/entidade_base.dart';
import '../../../core/utils/data_utils.dart';

class Categoria extends EntidadeBase {
  Color cor;
  int ordem;
  String? descricao;
  bool categoriaPadrao;

  // #region ======================== Construtores =========================

  Categoria({
    super.id,
    required super.titulo,
    required this.cor,
    required this.ordem,
    this.descricao,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
    this.categoriaPadrao = false,
  });

  static Categoria padrao() {
    return Categoria(
      id: null,
      titulo: '',
      cor: Cor.obterListaCores()[0],
      ordem: 0,
      descricao: null,
      dataCriacao: null,
      dataAlteracao: null,
      excluido: false,
      categoriaPadrao: false,
    );
  }

  Categoria copia() {
    return Categoria(
      id: id,
      titulo: titulo,
      cor: cor,
      ordem: ordem,
      descricao: descricao,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      excluido: excluido,
      categoriaPadrao: categoriaPadrao,
    );
  }

  // #endregion ===================== End Construtores ====================

  // #region ======================== Setters =============================
  Color setCor(Cor cor) => this.cor = Cor.obterCor(cor: cor);
  int setOrdem(int ordem) => this.ordem = ordem;
  void setDescricao(String descricao) {
    descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
  }

  // #endregion ===================== End Setters ==========================

  @override
  String toString() {
    return 'Categoria{\nid: $id, \ntitulo: $titulo, \ncor: $cor, '
        '\nordem: $ordem, \ndescricao: $descricao, '
        '\ndataCriacao: ${dataCriacao == null ? null : DataUtils.formatarDataHora(dataCriacao!)}, '
        '\ndataAlteracao: ${dataAlteracao == null ? null : DataUtils.formatarDataHora(dataAlteracao!)}, '
        '\nexcluido: $excluido \n}';
  }
}

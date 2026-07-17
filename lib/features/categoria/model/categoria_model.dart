import 'package:flutter/material.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/utils/data_utils.dart';

class Categoria {
  int? id;
  String titulo;
  Color cor;
  int ordem;
  String? descricao;
  DateTime? dtCriacao;
  DateTime? dtEdicao;
  bool estaExcluido;
  bool categoriaPadrao;

  // #region ======================== Construtores =========================

  Categoria({
    this.id,
    required this.titulo,
    required this.cor,
    required this.ordem,
    this.descricao,
    this.dtCriacao,
    this.dtEdicao,
    this.estaExcluido = false,
    this.categoriaPadrao = false,
  });

  static Categoria padrao() {
    return Categoria(
      id: null,
      titulo: '',
      cor: Cor.obterListaCores()[0],
      ordem: 0,
      descricao: null,
      dtCriacao: null,
      dtEdicao: null,
      estaExcluido: false,
      categoriaPadrao: false,
    );
  }

  // #endregion ===================== End Construtores ====================

  // #region ======================== Setters =============================
  String setTitulo(String titulo) => this.titulo = titulo;
  Color setCor(Cor cor) => this.cor = Cor.obterCor(cor: cor);
  int setOrdem(int ordem) => this.ordem = ordem;
  void setDescricao(String descricao) {
    descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
  }

  // #endregion ===================== End Setters ==========================

  @override
  String toString() {
    return 'Categoria{\nid: $id, \ntitulo: $titulo, \ncor: $cor, \nordem: $ordem, \ndescricao: $descricao, \ndtCriacao: ${DataUtils.dataParaStr(data: dtCriacao!)}, \ndtEdicao: ${DataUtils.dataParaStr(data: dtEdicao!)}, \nestaExcluido: $estaExcluido \n}';
  }
}

import 'package:mercado_list/data_recursos.dart';

import '../constants/schema/tb_categoria.dart';

import 'contrato.module.dart';

class Categoria implements ContratoModelo<Categoria> {
  int? id;
  String titulo;
  String cor;
  int ordem;
  String? descricao;
  DateTime? dtCriacao;
  DateTime? dtEdicao;
  bool estaExcluido;

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
  });

  static Categoria padrao() {
    return Categoria(
      id: null,
      titulo: '',
      cor: 'azul',
      ordem: 0,
      descricao: null,
      dtCriacao: null,
      dtEdicao: null,
      estaExcluido: false,
    );
  }

// #endregion ===================== End Construtores ====================

// #region ======================== Implementação ContratoModelo =========
  @override
  Categoria copia() {
    return Categoria(
      id: id,
      titulo: titulo,
      cor: cor,
      ordem: ordem,
      descricao: descricao,
      dtCriacao: dtCriacao,
      dtEdicao: dtEdicao,
      estaExcluido: estaExcluido,
    );
  }

  @override
  Categoria daNuvem(Map<String, dynamic> map) {
    return Categoria.padrao();
  }

  @override
  Categoria doBd(Map<String, dynamic> map) {
    return Categoria(
      id: map[TbCategoria.colunaId],
      titulo: map[TbCategoria.colunaTitulo],
      cor: map[TbCategoria.colunaCor],
      ordem: map[TbCategoria.colunaOrdem],
      descricao: map[TbCategoria.colunaDescricao],
      dtCriacao: RecursoDeData.strParaData(
          strData: map[TbCategoria.colunaDataCriacao]),
      dtEdicao: RecursoDeData.strParaData(
          strData: map[TbCategoria.colunaDataAlteracao]),
      estaExcluido: map[TbCategoria.colunaEstaExcluido] ?? 0,
    );
  }

  @override
  Map<String, dynamic> paraBd(Categoria objeto) {
    return {
      if (objeto.id != null) TbCategoria.colunaId: objeto.id,
      TbCategoria.colunaTitulo: objeto.titulo,
      TbCategoria.colunaCor: objeto.cor,
      TbCategoria.colunaOrdem: objeto.ordem,
      if (objeto.descricao != null) TbCategoria.colunaDescricao: objeto.descricao,
      if (objeto.dtCriacao != null)
        TbCategoria.colunaDataCriacao: objeto.dtCriacao!.toIso8601String(),
      if (objeto.dtEdicao != null)
        TbCategoria.colunaDataAlteracao: objeto.dtEdicao!.toIso8601String(),
      TbCategoria.colunaEstaExcluido: objeto.estaExcluido ? 1 : 0,
    };
  }

  @override
  Map<String, dynamic> paraNuvem(Categoria objeto) {
    return {};
  }

// #region ======================== Setters =============================
  setTitulo(String titulo) => this.titulo = titulo;
  setCor(String cor) => this.cor = cor;
  setOrdem(int ordem) => this.ordem = ordem;
  setDescricao(String descricao) {
    descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
  }

// #endregion ===================== End Setters ==========================
}

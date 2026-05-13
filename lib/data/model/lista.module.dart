import 'package:mercado_list/utils/data_utils.dart';

import '../db/schema/tb_lista.dart';

import 'contrato.module.dart';

class Lista implements ContratoModelo<Lista> {
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
  @override
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
  
  @override
  Lista daNuvem(Map<String, dynamic> map) {
    return Lista.padrao();
  }
  
  @override
  Lista doBd(Map<String, dynamic> map) {
    return Lista(
      id: map[TbLista.colunaId],
      titulo: map[TbLista.colunaTitulo],
      descricao: map[TbLista.colunaDescricao],
      dataCriacao: DataUtils.strParaData(strData:map[TbLista.colunaDataCriacao]),
      dataAlteracao: DataUtils.strParaData(strData:map[TbLista.colunaDataAlteracao]),
      estaExcluido: map[TbLista.colunaEstaExcluido] == 1 ? true : false,
    );
  }
  
  @override
  Map<String, dynamic> paraBd(Lista objeto) {
    return {
      if (objeto.id != null) TbLista.colunaId: objeto.id,
      TbLista.colunaTitulo: objeto.titulo,
      if (objeto.descricao != null) TbLista.colunaDescricao: objeto.descricao,
      if (objeto.dataCriacao != null) TbLista.colunaDataCriacao: objeto.dataCriacao!.toIso8601String(),
      if (objeto.dataAlteracao != null) TbLista.colunaDataAlteracao: objeto.dataAlteracao!.toIso8601String(),
      TbLista.colunaEstaExcluido: objeto.estaExcluido ? 1 : 0,
    };
  }
  
  @override
  Map<String, dynamic> paraNuvem(Lista objeto) {
    return {};
  }

// #endregion ===================== End Implementação ContratoModelo =====

// #region ======================== Setters ==================================
setTitulo(String titulo) => this.titulo = titulo;
setDescricao(String descricao) {
  descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
}


//#endregion ===================== End Setters ==============================
}

import '../../data_recursos.dart';
import '../constants/schema/tb_historico.dart';

import 'contrato.module.dart';

class Historico implements ContratoModelo<Historico> {
  int? id;
  String titulo;
  String? descricao;
  DateTime dataCompra;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool estaExcluido;

  // #region ======================== Construtores =========================

  Historico({
    this.id,
    required this.titulo,
    this.descricao,
    required this.dataCompra,
    this.dataCriacao,
    this.dataAlteracao,
    this.estaExcluido = false,
  });

  static Historico padrao() {
    return Historico(
      id: null,
      titulo: '',
      descricao: null,
      dataCompra: DateTime.now(),
      dataCriacao: null,
      dataAlteracao: null,
    );
  }

  // #endregion ===================== End Construtores ====================


// #region ======================== Implementação ContratoModelo =========
  @override
  Historico copia() {
    return Historico(
      id: id,
      titulo: titulo,
      descricao: descricao,
      dataCompra: dataCompra,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      estaExcluido: estaExcluido,
    );
  }

  @override
  Historico daNuvem(Map<String, dynamic> map) {
    return Historico.padrao();
  }

  @override
  Historico doBd(Map<String, dynamic> map) {
    return Historico(
      id: map[TbHistorico.colunaId],
      titulo: map[TbHistorico.colunaTitulo],
      descricao: map[TbHistorico.colunaDescricao],
      dataCompra: RecursoDeData.strParaData(
          strData: map[TbHistorico.colunaDataCompra]!),
      dataCriacao: RecursoDeData.strParaData(
          strData: map[TbHistorico.colunaDataCriacao]!),
      dataAlteracao: RecursoDeData.strParaData(
          strData: map[TbHistorico.colunaDataAlteracao]!),
      estaExcluido: map[TbHistorico.colunaEstaExcluido] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> paraBd(Historico objeto) {
    return {
      if (objeto.id != null) TbHistorico.colunaId: objeto.id,
      TbHistorico.colunaTitulo: objeto.titulo,
      if (objeto.descricao != null) TbHistorico.colunaDescricao: objeto.descricao,
      TbHistorico.colunaDataCompra: objeto.dataCompra.toIso8601String(),
      if (objeto.dataCriacao != null) TbHistorico.colunaDataCriacao:
          objeto.dataCriacao!.toIso8601String(),
      if (objeto.dataAlteracao != null) TbHistorico.colunaDataAlteracao:
          objeto.dataAlteracao!.toIso8601String(),
      TbHistorico.colunaEstaExcluido: objeto.estaExcluido ? 1 : 0,
    };
  }

  @override
  Map<String, dynamic> paraNuvem(Historico objeto) {
    return {};
  }

// #endregion ===================== End Implementação ContratoModelo ========


//#region ======================== Setters ==================================
setTitulo(String titulo) => this.titulo = titulo;
setDescricao(String descricao) {
  descricao.isEmpty ? this.descricao = null : this.descricao = descricao;
}
setDataCompra(DateTime dataCompra) => this.dataCompra = dataCompra;

//#endregion ===================== End Setters ==============================
}
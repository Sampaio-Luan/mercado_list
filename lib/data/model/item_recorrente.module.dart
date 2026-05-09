import '../../data_recursos.dart';
import '../constants/schema/tb_item_recorrente.dart';

import 'contrato.module.dart';

class ItemRecorrente implements ContratoModelo<ItemRecorrente> {
  int? id;
  int idCategoria;
  String titulo;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool estaExcluido;


// #region ======================== Construtores =========================
  ItemRecorrente({
    this.id,
    required this.idCategoria,
    required this.titulo,
    this.dataCriacao,
    this.dataAlteracao,
    this.estaExcluido = false,
  });

  static ItemRecorrente padrao({required int idCategoria}) {
    return ItemRecorrente(
      id: null,
      idCategoria: idCategoria,
      titulo: '',
      dataCriacao: null,
      dataAlteracao: null,
      estaExcluido: false,
    );
  }

  @override
  ItemRecorrente copia() {
    return ItemRecorrente(
      id: id,
      idCategoria: idCategoria,
      titulo: titulo,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      estaExcluido: estaExcluido,
    );
  }


// #endregion ===================== End Construtores ====================


// #region ======================== Implementação ContratoModelo =========
  @override
  ItemRecorrente daNuvem(Map<String, dynamic> map) {
    return ItemRecorrente.padrao(idCategoria: 1);
  }

  @override
  ItemRecorrente doBd(Map<String, dynamic> map) {
    return ItemRecorrente(
      id: map[TbItemRecorrente.colunaId],
      idCategoria: map[TbItemRecorrente.colunaIdCategoria],
      titulo: map[TbItemRecorrente.colunaTitulo],
      dataCriacao:  RecursoDeData.strParaData(strData: map[TbItemRecorrente.colunaDataCriacao]),
      dataAlteracao:  RecursoDeData.strParaData(strData: map[TbItemRecorrente.colunaDataAlteracao]),
      estaExcluido: map[TbItemRecorrente.colunaEstaExcluido] == 0 ? false : true,
    );
  }

  @override
  Map<String, dynamic> paraBd(ItemRecorrente objeto) {
   Map<String, dynamic>  map = {
      TbItemRecorrente.colunaId: objeto.id,
      TbItemRecorrente.colunaIdCategoria: objeto.idCategoria,
      TbItemRecorrente.colunaTitulo: objeto.titulo,
      if (objeto.dataCriacao != null) TbItemRecorrente.colunaDataCriacao: objeto.dataCriacao!.toIso8601String(),
      if (objeto.dataAlteracao != null) TbItemRecorrente.colunaDataAlteracao: objeto.dataAlteracao!.toIso8601String(),
      TbItemRecorrente.colunaEstaExcluido: objeto.estaExcluido ? 1 : 0,
    };
    return map;
  }

  @override
  Map<String, dynamic> paraNuvem(ItemRecorrente objeto) {
    return {};
  }

//#endregion ===================== End Implementação ContratoModelo =====

// #region ======================== Setters =============================================
  void setTitulo(String titulo) {
    this.titulo = titulo;
  }

  void setEstaExcluido() => estaExcluido = !estaExcluido;
}

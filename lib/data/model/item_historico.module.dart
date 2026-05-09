import 'package:mercado_list/data_recursos.dart';

import '../constants/enum/tipo_medida.dart';
import '../constants/schema/tb_item_historico.dart';

import 'contrato.module.dart';
import 'item.module.dart';

class ItemHistorico implements ContratoModelo<ItemHistorico> {
  int? id;
  int idHistorico;
  String titulo;
  String tituloCategoria;
  TipoMedida unidadeMedida;
  int quantidade;
  int preco;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool estaExcluido;

// #region ======================== Construtores =========================
  ItemHistorico({
    this.id,
    required this.idHistorico,
    required this.titulo,
    required this.tituloCategoria,
    required this.unidadeMedida,
    required this.quantidade,
    required this.preco,
    this.dataCriacao,
    this.dataAlteracao,
    this.estaExcluido = false,
  });

  static ItemHistorico padrao({
    required Item item,
    required String tituloCategoria,
    required int idHistorico,
  }) {
    return ItemHistorico(
      id: null,
      idHistorico: idHistorico,
      titulo: item.titulo,
      tituloCategoria: tituloCategoria,
      unidadeMedida: item.unidadeMedida,
      quantidade: item.quantidade,
      preco: item.preco,
      dataCriacao: null,
      dataAlteracao: null,
      estaExcluido: false,
    );
  }
// #endregion ===================== End Construtores ====================

// #region ======================== Implementação ContratoModelo =========
  @override
  ItemHistorico copia() {
    return ItemHistorico(
      id: id,
      idHistorico: idHistorico,
      tituloCategoria: tituloCategoria,
      titulo: titulo,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      estaExcluido: estaExcluido,
      unidadeMedida: unidadeMedida,
      quantidade: quantidade,
      preco: preco,
    );
  }

  @override
  ItemHistorico daNuvem(Map<String, dynamic> map) {
    return ItemHistorico.padrao(
      idHistorico: 1,
      item: Item.padrao(idCategoria: 1, idLista: 1),
      tituloCategoria: 'categoria',
    );
  }

  @override
  ItemHistorico doBd(Map<String, dynamic> map) {
    return ItemHistorico(
        id: map[TbItemHistorico.colunaId],
        idHistorico: map[TbItemHistorico.colunaIdHistorico],
        tituloCategoria: map[TbItemHistorico.colunaTituloCategoria],
        titulo: map[TbItemHistorico.colunaTitulo],
        dataCriacao: RecursoDeData.strParaData(
            strData: map[TbItemHistorico.colunaDataCriacao]!),
        dataAlteracao:
            RecursoDeData.strParaData(strData: map[TbItemHistorico.colunaDataAlteracao]!),
        estaExcluido: map[TbItemHistorico.colunaEstaExcluido] == 1 ? true : false,
        unidadeMedida: TipoMedida.obterPorRotulo(
            rotulo: map[TbItemHistorico.colunaUnidadeDeMedida]!),
        quantidade: map[TbItemHistorico.colunaQuantidade],
        preco: map[TbItemHistorico.colunaPreco]);
  }

  @override
  Map<String, dynamic> paraBd(ItemHistorico objeto) {
    return {
      if (objeto.id != null) TbItemHistorico.colunaId: objeto.id,
      TbItemHistorico.colunaIdHistorico: objeto.idHistorico,
      TbItemHistorico.colunaTitulo: objeto.titulo,
      TbItemHistorico.colunaTituloCategoria: objeto.tituloCategoria,
      TbItemHistorico.colunaQuantidade: objeto.quantidade,
      TbItemHistorico.colunaPreco: objeto.preco,
      TbItemHistorico.colunaUnidadeDeMedida: TipoMedida.obterRotulo(tipo: objeto.unidadeMedida),
      if (objeto.dataCriacao != null)
        TbItemHistorico.colunaDataCriacao: objeto.dataCriacao!.toIso8601String(),
      if (objeto.dataAlteracao != null)
        TbItemHistorico.colunaDataAlteracao: objeto.dataAlteracao!.toIso8601String(),
      TbItemHistorico.colunaEstaExcluido: objeto.estaExcluido ? 1 : 0,
    };
  }

  @override
  Map<String, dynamic> paraNuvem(ItemHistorico objeto) {
    return {};
  }

// #endregion ===================== End ContratoModelo ====================
}

import 'package:mercado_list/data/constants/enum/prioridade.dart';
import 'package:mercado_list/data/constants/enum/tipo_medida.dart';
import 'package:mercado_list/data/db/schema/tb_item.dart';
import 'package:mercado_list/data_recursos.dart';

import 'contrato.module.dart';

class Item implements ContratoModelo<Item> {
  int? id;
  int idLista;
  int idCategoria;
  String titulo;
  String? observacao;
  TipoMedida unidadeMedida;
  int preco;
  int quantidade;
  Prioridade prioridade;
  bool obtido;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool estaExcluido;

//#region ======================== Construtores ========================================

  Item({
    required this.id,
    required this.idLista,
    required this.idCategoria,
    required this.titulo,
    required this.observacao,
    required this.unidadeMedida,
    required this.preco,
    required this.quantidade,
    required this.prioridade,
    required this.obtido,
    required this.dataCriacao,
    required this.dataAlteracao,
    required this.estaExcluido,
  });

  static Item padrao({required int idLista, required int idCategoria}) {
    return Item(
      id: null,
      idLista: idLista,
      idCategoria: idCategoria,
      titulo: '',
      observacao: null,
      unidadeMedida: TipoMedida.und,
      preco: 0,
      quantidade: 1,
      prioridade: Prioridade.neutra,
      obtido: false,
      dataCriacao: null,
      dataAlteracao: null,
      estaExcluido: false,
    );
  }

  @override
  Item copia () => Item(
    id: id,
    idLista: idLista,
    idCategoria: idCategoria,
    titulo: titulo,
    observacao: observacao,
    unidadeMedida: unidadeMedida,
    preco: preco,
    quantidade: quantidade,
    prioridade: prioridade,
    obtido: obtido,
    dataCriacao: dataCriacao,
    dataAlteracao: dataAlteracao,
    estaExcluido: estaExcluido
  );
  
//#endregion ===================== End Construtores ====================================

//#region ======================== Implementação ContratoModelo ========================
  @override
  Map<String, dynamic> paraBd(Item objeto) {
    Map<String, dynamic> map = {
      if (objeto.id != null) TbItem.colunaId: objeto.id,
      TbItem.colunaIdLista: objeto.idLista,
      TbItem.colunaIdCategoria: objeto.idCategoria,
      TbItem.colunaTitulo: objeto.titulo,
      if (objeto.observacao != null) TbItem.colunaObservacao: objeto.observacao,
      TbItem.colunaUnidadeMedida:
          TipoMedida.obterRotulo(tipo: objeto.unidadeMedida),
      TbItem.colunaPreco: objeto.preco,
      TbItem.colunaQuantidade: objeto.quantidade,
      TbItem.colunaPrioridade:
          Prioridade.obterRotulo(prioridade: objeto.prioridade),
      TbItem.colunaObtido: objeto.obtido,
      if (objeto.dataCriacao != null)
        TbItem.colunaDataCriacao: objeto.dataCriacao!.toIso8601String(),
      if (objeto.dataAlteracao != null)
        TbItem.colunaDataAlteracao: objeto.dataAlteracao!.toIso8601String(),
      TbItem.colunaEstaExcluido: objeto.estaExcluido
    };
    return map;
  }

  @override
  Item doBd(Map<String, dynamic> map) {
    return Item(
      id: map[TbItem.colunaId],
      idLista: map[TbItem.colunaIdLista],
      idCategoria: map[TbItem.colunaIdCategoria],
      titulo: map[TbItem.colunaTitulo],
      observacao: map[TbItem.colunaObservacao],
      unidadeMedida:
          TipoMedida.obterPorRotulo(rotulo: map[TbItem.colunaUnidadeMedida]),
      preco: map[TbItem.colunaPreco],
      quantidade: map[TbItem.colunaQuantidade],
      prioridade:
          Prioridade.obterPorRotulo(rotulo: map[TbItem.colunaPrioridade]),
      obtido: map[TbItem.colunaObtido] == 0 ? false : true,
      dataCriacao:
          RecursoDeData.strParaData(strData: map[TbItem.colunaDataCriacao]),
      dataAlteracao:
          RecursoDeData.strParaData(strData: map[TbItem.colunaDataAlteracao]),
      estaExcluido: map[TbItem.colunaEstaExcluido] == 0 ? false : true,
    );
  }

  @override
  Map<String, dynamic> paraNuvem(Item objeto) {
    return {};
  }

  @override
  Item daNuvem(Map<String, dynamic> map) {
    return Item(
      id: map[TbItem.colunaId],
      idLista: map[TbItem.colunaIdLista],
      idCategoria: map[TbItem.colunaIdCategoria],
      titulo: map[TbItem.colunaTitulo],
      observacao: map[TbItem.colunaObservacao],
      unidadeMedida:
          TipoMedida.obterPorRotulo(rotulo: map[TbItem.colunaUnidadeMedida]),
      preco: map[TbItem.colunaPreco],
      quantidade: map[TbItem.colunaQuantidade],
      prioridade:
          Prioridade.obterPorRotulo(rotulo: map[TbItem.colunaPrioridade]),
      obtido: map[TbItem.colunaObtido] == 0 ? false : true,
      dataCriacao:
          RecursoDeData.strParaData(strData: map[TbItem.colunaDataCriacao]),
      dataAlteracao:
          RecursoDeData.strParaData(strData: map[TbItem.colunaDataAlteracao]),
      estaExcluido: map[TbItem.colunaEstaExcluido] == 0 ? false : true,
    );
  }
//#endregion ===================== End ContratoModelo ==================================

//#region ======================== Setters =============================================
  void setTitulo(String titulo) {
    this.titulo = titulo;
  }

  void setObservacao(String observacao) {
    this.observacao = observacao.isEmpty ? null : observacao;
  }

  void setUnidadeMedida(TipoMedida unidadeMedida) {
    this.unidadeMedida = unidadeMedida;
  }

  void setPreco(String preco) {
    this.preco = preco.isEmpty
        ? 0
        : int.parse(preco.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  void setQuantidade(String quantidade) {
    quantidade.isEmpty
        ? this.quantidade = 1
        : this.quantidade = int.parse(quantidade);
  }

  void setPrioridade(Prioridade prioridade) {
    this.prioridade = prioridade;
  }

  void setObtido() => obtido = !obtido;

  void setEstaExcluido() => estaExcluido = !estaExcluido;

//#endregion ======================== End Setters =========================================

}



import '../../../core/constants/enums/tipo_medida.dart';

class ItemRecorrente{
  int? id;
  int idCategoria;
  String titulo;
  TipoMedida tipoMedida;
  DateTime? dataCriacao;
  DateTime? dataAlteracao;
  bool estaExcluido;


// #region ======================== Construtores =========================
  ItemRecorrente({
    this.id,
    required this.idCategoria,
    required this.titulo,
    required this.tipoMedida,
    this.dataCriacao,
    this.dataAlteracao,
    this.estaExcluido = false,
  });

  static ItemRecorrente padrao({required int idCategoria}) {
    return ItemRecorrente(
      id: null,
      idCategoria: idCategoria,
      titulo: '',
      tipoMedida:  TipoMedida.und,
      dataCriacao: null,
      dataAlteracao: null,
      estaExcluido: false,
    );
  }


  ItemRecorrente copia() {
    return ItemRecorrente(
      id: id,
      idCategoria: idCategoria,
      titulo: titulo,
      tipoMedida: tipoMedida,
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      estaExcluido: estaExcluido,
    );
  }

// #region ======================== Setters =============================================
  void setTitulo(String titulo) {
    this.titulo = titulo;
  }

  void setEstaExcluido() => estaExcluido = !estaExcluido;
}

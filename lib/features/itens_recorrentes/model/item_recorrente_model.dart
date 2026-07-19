import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/model/entidade_base.dart';

class ItemRecorrente extends EntidadeBase {
  int idCategoria;
  TipoMedida tipoMedida;

// #region ======================== Construtores =========================
  ItemRecorrente({
    super.id,
    required this.idCategoria,
    required super.titulo,
    required this.tipoMedida,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  });

  static ItemRecorrente padrao({required int idCategoria}) {
    return ItemRecorrente(
      id: null,
      idCategoria: idCategoria,
      titulo: '',
      tipoMedida: TipoMedida.und,
      dataCriacao: null,
      dataAlteracao: null,
      excluido: false,
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
      excluido: excluido,
    );
  }

// #region ======================== Setters =============================================
}

import '../../../core/constants/enums/cores.dart';
import '../../../core/contracts/contrato_mapper.dart';
import '../../../core/database/schema/tb_categoria.dart';
import '../../../core/utils/data_utils.dart';

import '../model/categoria_model.dart';

class CategoriaMapper implements ContratoMapper<Categoria> {
  @override
  Categoria daNuvem(Map<String, dynamic> map) {
    return Categoria.padrao();
  }

  @override
  Categoria doMapa(Map<String, dynamic> map) {
    return Categoria(
      id: map[TbCategoria.colunaId],
      titulo: map[TbCategoria.colunaTitulo],
      cor: Cor.obterCor(
        cor: Cor.obterPorRotulo(rotulo: map[TbCategoria.colunaCor]),
      ),
      ordem: map[TbCategoria.colunaOrdem],
      descricao: map[TbCategoria.colunaDescricao],
      dtCriacao: DataUtils.strParaData(
        strData: map[TbCategoria.colunaDataCriacao],
      ),
      dtEdicao: DataUtils.strParaData(
        strData: map[TbCategoria.colunaDataAlteracao],
      ),
      estaExcluido: map[TbCategoria.colunaEstaExcluido] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> paraMapa(Categoria objeto) {

    return {
      if (objeto.id != null) TbCategoria.colunaId: objeto.id,
      TbCategoria.colunaTitulo: objeto.titulo,
      TbCategoria.colunaCor: Cor.obterPorColor(color: objeto.cor).name,
      TbCategoria.colunaOrdem: objeto.ordem,
      if (objeto.descricao != null)
        TbCategoria.colunaDescricao: objeto.descricao,
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
}

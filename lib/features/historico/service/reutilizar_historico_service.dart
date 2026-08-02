import '../../../core/constants/enums/tipo_medida.dart';
import '../../../core/utils/texto_utils.dart';
import '../../categoria/model/categoria_model.dart';
import '../../categoria/service/categorias_service.dart';
import '../../itens/model/item_model.dart';
import '../../itens/service/itens_service.dart';
import '../../listas/model/lista_model.dart';
import '../model/historico_com_itens_model.dart';
import '../model/resultado_reutilizacao_historico.dart';

abstract interface class ReutilizarHistoricoServiceContract {
  Future<ResultadoReutilizacaoHistorico> executar({
    required HistoricoComItens compra,
    required Lista listaDestino,
    bool adicionarDuplicados = false,
  });
}

class ReutilizarHistoricoService implements ReutilizarHistoricoServiceContract {
  const ReutilizarHistoricoService(
    this._itensService,
    this._categoriasService,
  );

  final ItensServiceContract _itensService;
  final CategoriasServiceContract _categoriasService;

  @override
  Future<ResultadoReutilizacaoHistorico> executar({
    required HistoricoComItens compra,
    required Lista listaDestino,
    bool adicionarDuplicados = false,
  }) async {
    final idLista = listaDestino.id;
    if (idLista == null || idLista <= 0) {
      throw StateError('Selecione uma lista válida para reutilizar a compra.');
    }
    final resultados = await Future.wait([
      _itensService.buscarPorLista(idLista),
      _categoriasService.recuperarTodos(),
    ]);
    final existentes = resultados[0] as List<Item>;
    final categorias = resultados[1] as List<Categoria>;
    final titulosExistentes = existentes
        .map((item) => TextoUtils.normalizarParaOrdenacao(item.titulo))
        .toSet();
    var adicionados = 0;
    var ignorados = 0;
    for (final item in compra.itens) {
      final tituloNormalizado = TextoUtils.normalizarParaOrdenacao(item.titulo);
      if (!adicionarDuplicados &&
          titulosExistentes.contains(tituloNormalizado)) {
        ignorados++;
        continue;
      }
      final categoria = categorias.where(
        (categoria) =>
            TextoUtils.normalizarParaOrdenacao(categoria.titulo) ==
            TextoUtils.normalizarParaOrdenacao(item.tituloCategoria),
      );
      final idCategoria = categoria.isEmpty ? 0 : categoria.first.id!;
      await _itensService.criar(
        Item(
          idLista: idLista,
          idCategoria: idCategoria,
          titulo: item.titulo,
          tipoMedida:
              item.unidadeMedida == 'kg' ? TipoMedida.kg : TipoMedida.und,
          quantidade: item.quantidade,
          preco: item.preco == 0 ? null : item.preco,
          observacao: item.observacao,
          prioridade: item.prioridade,
          obtido: false,
        ),
      );
      titulosExistentes.add(tituloNormalizado);
      adicionados++;
    }
    return ResultadoReutilizacaoHistorico(
      adicionados: adicionados,
      ignorados: ignorados,
    );
  }
}

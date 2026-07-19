import '../../../core/contracts/gerenciador_transacoes.dart';
import '../../../core/model/progresso_operacao.dart';
import '../../../core/utils/data_utils.dart';
import '../../itens_recorrentes/service/item_recorrente_service.dart';
import '../model/categoria_model.dart';
import '../model/resultado_exclusao_categoria.dart';
import 'categorias_service.dart';

abstract interface class ExcluirCategoriaContract {
  Future<ResultadoExclusaoCategoria> executar(
    Categoria categoria, {
    required int idCategoriaPadraoEsperada,
    AoProgredir? aoProgredir,
  });
}

class ExcluirCategoriaService implements ExcluirCategoriaContract {
  final GerenciadorTransacoes _gerenciadorTransacoes;
  final CategoriasServiceContract _categoriasService;
  final ItemRecorrenteService _itemRecorrenteService;

  ExcluirCategoriaService(
    this._gerenciadorTransacoes,
    this._categoriasService,
    this._itemRecorrenteService,
  );

  @override
  Future<ResultadoExclusaoCategoria> executar(
    Categoria categoria, {
    required int idCategoriaPadraoEsperada,
    AoProgredir? aoProgredir,
  }) {
    return _gerenciadorTransacoes.executar((executor) async {
      final dataAlteracao = DataUtils.agoraUtc();
      _informar(
        aoProgredir,
        1,
        'Localizando a categoria padrão...',
      );
      final categoriaPadrao = await _categoriasService.prepararExclusao(
        categoria,
        databaseExecutor: executor,
      );
      if (categoriaPadrao.id != idCategoriaPadraoEsperada) {
        throw StateError('A categoria padrão em memória está desatualizada.');
      }

      _informar(aoProgredir, 2, 'Buscando os itens recorrentes...');
      final itens = await _itemRecorrenteService.buscarPorCategoria(
        idCategoria: categoria.id!,
        databaseExecutor: executor,
      );

      _informar(aoProgredir, 3, _descricaoMovimentacao(itens.length));
      await _itemRecorrenteService.moverParaCategoria(
        itens: itens,
        categoriaOrigem: categoria.id!,
        categoriaDestino: categoriaPadrao.id!,
        databaseExecutor: executor,
        dataAlteracao: dataAlteracao,
      );

      _informar(aoProgredir, 4, 'Excluindo a categoria...');
      await _categoriasService.excluir(
        categoria,
        databaseExecutor: executor,
        dataAlteracao: dataAlteracao,
      );

      return ResultadoExclusaoCategoria(
        categoriaPadrao: categoriaPadrao,
        quantidadeItensMovidos: itens.length,
        dataAlteracao: dataAlteracao,
      );
    });
  }

  void _informar(AoProgredir? aoProgredir, int etapa, String descricao) {
    aoProgredir?.call(
      ProgressoOperacao(etapa: etapa, total: 5, descricao: descricao),
    );
  }

  String _descricaoMovimentacao(int quantidade) {
    if (quantidade == 0) {
      return 'Nenhum item recorrente precisa ser movido.';
    }
    if (quantidade == 1) {
      return 'Movendo 1 item recorrente...';
    }
    return 'Movendo $quantidade itens recorrentes...';
  }
}

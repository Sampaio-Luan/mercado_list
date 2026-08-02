import '../../categoria/model/categoria_model.dart';
import '../../categoria/service/categorias_service.dart';
import '../../itens/model/item_model.dart';
import '../../itens/service/itens_service.dart';
import '../../listas/model/lista_model.dart';
import '../model/compartilhamento_model.dart';

class PrepararConteudoCompartilhamentoService {
  const PrepararConteudoCompartilhamentoService(
    this._itensService,
    this._categoriasService,
  );

  final ItensServiceContract _itensService;
  final CategoriasServiceContract _categoriasService;

  Future<ConteudoCompartilhamento> prepararLista(
    Lista lista, {
    ContextoCompartilhamento contexto = ContextoCompartilhamento.lista,
  }) async {
    final idLista = lista.id;
    if (idLista == null || idLista <= 0) {
      throw StateError('A lista precisa estar persistida para compartilhar.');
    }
    final resultados = await Future.wait([
      _itensService.buscarPorLista(idLista),
      _categoriasService.recuperarTodos(),
    ]);
    return prepararComDados(
      lista,
      itens: resultados[0] as List<Item>,
      categorias: resultados[1] as List<Categoria>,
      contexto: contexto,
    );
  }

  ConteudoCompartilhamento prepararComDados(
    Lista lista, {
    required Iterable<Item> itens,
    required Iterable<Categoria> categorias,
    ContextoCompartilhamento contexto = ContextoCompartilhamento.itensDaLista,
  }) {
    final titulosCategorias = {
      for (final categoria in categorias)
        if (categoria.id != null) categoria.id!: categoria.titulo,
    };
    return ConteudoCompartilhamento(
      contexto: contexto,
      titulo: lista.titulo,
      descricao: lista.descricao,
      orcamento: lista.orcamento,
      itens: itens
          .map(
            (item) => ItemCompartilhamento(
              titulo: item.titulo,
              categoria: titulosCategorias[item.idCategoria] ?? 'Sem categoria',
              quantidade: item.quantidade,
              unidade: item.tipoMedida.name,
              preco: item.preco,
              total: item.valorTotal,
              prioridade: _rotuloPrioridade(item.prioridade.name),
              observacao: item.observacao,
              marcado: item.obtido,
            ),
          )
          .toList(growable: false),
    );
  }

  String _rotuloPrioridade(String prioridade) => switch (prioridade) {
        'baixa' => 'Baixa',
        'media' => 'Média',
        'alta' => 'Alta',
        _ => 'Neutra',
      };
}

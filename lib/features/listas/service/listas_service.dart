import 'package:sqflite/sqflite.dart';

import '../../../core/contracts/gerenciador_transacoes.dart';
import '../../../core/utils/data_utils.dart';
import '../../itens/model/item_model.dart';
import '../../itens/service/itens_service.dart';
import '../model/lista_com_resumo_de_itens_model.dart';
import '../model/lista_model.dart';
import '../repository/lista_repository.dart';

abstract interface class ListasServiceContract {
  Future<Lista> criar(Lista lista);
  Future<Lista> editar(Lista lista);
  Future<List<ListaComResumoDeItens>> recuperarComResumo();
  Future<void> atualizarOrdens(List<Lista> listas);
  Future<void> excluir(Lista lista);
  Future<Lista> copiar(Lista lista);
}

class ListasService implements ListasServiceContract {
  static const int limiteFixadas = 3;

  final ListaRepositoryContract _repository;
  final ItensService _itensService;
  final GerenciadorTransacoes _gerenciadorTransacoes;

  ListasService(
    this._repository,
    this._itensService,
    this._gerenciadorTransacoes,
  );

  @override
  Future<Lista> criar(Lista lista) async {
    if (lista.id != null) throw StateError('Uma nova lista não pode ter id.');
    _normalizar(lista);
    if (lista.fixada) {
      return _gerenciadorTransacoes.executar((executor) async {
        await _validarLimiteFixadas(databaseExecutor: executor);
        return _repository.criar(lista, databaseExecutor: executor);
      });
    }
    return _repository.criar(lista);
  }

  @override
  Future<Lista> editar(Lista lista) async {
    if (lista.id == null || lista.id! <= 0) {
      throw StateError('A lista precisa estar persistida para ser editada.');
    }
    _normalizar(lista);
    final persistida = await _repository.recuperar(lista.id!);
    if (!persistida.fixada && lista.fixada) {
      return _gerenciadorTransacoes.executar((executor) async {
        await _validarLimiteFixadas(databaseExecutor: executor);
        return _repository.editar(lista, databaseExecutor: executor);
      });
    }
    return _repository.editar(lista);
  }

  @override
  Future<List<ListaComResumoDeItens>> recuperarComResumo() {
    return _repository.recuperarComResumo();
  }

  @override
  Future<void> atualizarOrdens(List<Lista> listas) async {
    if (listas.any((lista) => lista.id == null)) {
      throw StateError('Todas as listas devem estar persistidas.');
    }
    await _repository.atualizarOrdens(listas);
  }

  @override
  Future<void> excluir(Lista lista) {
    if (lista.id == null || lista.id! <= 0) {
      throw StateError('A lista precisa estar persistida para ser excluída.');
    }
    return _gerenciadorTransacoes.executar((executor) async {
      final agora = DataUtils.agoraUtc();
      await _itensService.excluirPorLista(
        lista.id!,
        dataAlteracao: agora,
        databaseExecutor: executor,
      );
      await _repository.excluir(
        lista.id!,
        databaseExecutor: executor,
        dataAlteracao: agora,
      );
      final restantes = await _recuperarTodos(executor);
      await _repository.atualizarOrdens(
        restantes,
        databaseExecutor: executor,
        dataAlteracao: agora,
      );
    });
  }

  @override
  Future<Lista> copiar(Lista lista) {
    if (lista.id == null || lista.id! <= 0) {
      throw StateError('A lista precisa estar persistida para ser copiada.');
    }
    return _gerenciadorTransacoes.executar((executor) async {
      final origem = await _repository.recuperar(
        lista.id!,
        databaseExecutor: executor,
      );
      final itens = await _buscarItens(origem.id!, executor);
      final copia = origem.copia()
        ..id = null
        ..titulo = '${origem.titulo} (Cópia)'
        ..fixada = false
        ..dataCriacao = null
        ..dataAlteracao = null;
      final criada = await _repository.criar(
        copia,
        databaseExecutor: executor,
      );
      await _itensService.copiarParaLista(
        itens,
        criada.id!,
        databaseExecutor: executor,
      );
      return criada;
    });
  }

  Future<List<Item>> _buscarItens(
    int idLista,
    DatabaseExecutor executor,
  ) {
    return _itensService.buscarPorLista(
      idLista,
      databaseExecutor: executor,
    );
  }

  Future<List<Lista>> _recuperarTodos(DatabaseExecutor executor) {
    return _repository.recuperarTodosNoExecutor(executor);
  }

  Future<void> _validarLimiteFixadas({
    DatabaseExecutor? databaseExecutor,
  }) async {
    if (await _repository.contarFixadas(
          databaseExecutor: databaseExecutor,
        ) >=
        limiteFixadas) {
      throw StateError('Você pode fixar no máximo 3 listas.');
    }
  }

  void _normalizar(Lista lista) {
    lista.titulo = lista.titulo.trim();
    if (lista.titulo.isEmpty) {
      throw ArgumentError('O título da lista é obrigatório.');
    }
    final descricao = lista.descricao?.trim();
    lista.descricao = descricao == null || descricao.isEmpty ? null : descricao;
    if (lista.orcamento != null && lista.orcamento! < 0) {
      throw ArgumentError('O orçamento não pode ser negativo.');
    }
  }
}

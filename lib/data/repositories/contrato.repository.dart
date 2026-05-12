abstract class ContratoRepository<T> {
  static String msgId = '';
  Future<void> criar(T objeto);
  Future<void> editar(T objeto);
  Future<void> recuperar(int id);
  Future<void> recuperarTodos();
  Future<void> excluir(int id);
}
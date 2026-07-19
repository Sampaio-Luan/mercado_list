abstract interface class ContratoRepository<T> {
  Future<T> criar(T objeto);
  Future<T> editar(T objeto);
  Future<T> recuperar(int id);
  Future<List<T>> recuperarTodos();
  Future<void> excluir(int id);
}

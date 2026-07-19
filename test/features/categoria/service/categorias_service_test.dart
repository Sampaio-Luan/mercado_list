import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/core/database/banco_local.dart';
import 'package:mercado_list/features/categoria/mapper/categoria_mapper.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/repository/categoria_repository.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('impede a preparação da exclusão da categoria padrão', () async {
    final service = CategoriasService(
      CategoriasRepository(
        bancoLocal: BancoLocal.instancia,
        categoriaMapper: CategoriaMapper(),
      ),
    );
    final categoriaPadrao = Categoria(
      id: 1,
      titulo: 'Outros',
      cor: Cor.obterCor(cor: Cor.indigo),
      ordem: 1,
      categoriaPadrao: true,
    );

    await expectLater(
      service.prepararExclusao(categoriaPadrao),
      throwsA(
        isA<StateError>().having(
          (erro) => erro.message,
          'mensagem',
          'A categoria padrão não pode ser excluída.',
        ),
      ),
    );
  });

  test('edição normaliza título e preserva campos controlados pelo sistema',
      () async {
    final persistida = Categoria(
      id: 2,
      titulo: 'Alimento',
      cor: Cor.obterCor(cor: Cor.laranja),
      ordem: 7,
      excluido: false,
    );
    final repository = _CategoriasRepositoryFake(persistida);
    final service = CategoriasService(repository);
    final rascunho = persistida.copia()
      ..titulo = '  Alimentos  '
      ..ordem = 99
      ..excluido = true;

    final editada = await service.editar(rascunho);

    expect(editada.titulo, 'Alimentos');
    expect(repository.categoriaRecebida?.ordem, 7);
    expect(repository.categoriaRecebida?.excluido, isFalse);
    expect(repository.categoriaRecebida?.categoriaPadrao, isFalse);
  });

  test('impede alteração do título da categoria padrão', () async {
    final persistida = Categoria(
      id: 1,
      titulo: 'Sem categoria',
      cor: Cor.obterCor(cor: Cor.marrom),
      ordem: 1,
      categoriaPadrao: true,
    );
    final service = CategoriasService(_CategoriasRepositoryFake(persistida));

    await expectLater(
      service.editar(persistida.copia()..titulo = 'Outros'),
      throwsA(
        isA<StateError>().having(
          (erro) => erro.message,
          'mensagem',
          'O título da categoria padrão não pode ser alterado.',
        ),
      ),
    );
  });
}

class _CategoriasRepositoryFake extends CategoriasRepository {
  final Categoria persistida;
  Categoria? categoriaRecebida;

  _CategoriasRepositoryFake(this.persistida)
      : super(
          bancoLocal: BancoLocal.instancia,
          categoriaMapper: CategoriaMapper(),
        );

  @override
  Future<Categoria> recuperar(
    int id, {
    DatabaseExecutor? databaseExecutor,
  }) async =>
      persistida.copia();

  @override
  Future<Categoria> editar(
    Categoria objeto, {
    DatabaseExecutor? databaseExecutor,
  }) async {
    categoriaRecebida = objeto.copia();
    return categoriaRecebida!;
  }
}

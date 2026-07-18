import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/core/database/banco_local.dart';
import 'package:mercado_list/features/categoria/mapper/categoria_mapper.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/repository/categoria_repository.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';

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
}

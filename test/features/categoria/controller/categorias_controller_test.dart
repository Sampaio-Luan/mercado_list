import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/cor.dart';
import 'package:mercado_list/core/constants/enums/estado_de_tela.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/database/banco_local.dart';
import 'package:mercado_list/features/categoria/controller/categorias_controller.dart';
import 'package:mercado_list/features/categoria/mapper/categoria_mapper.dart';
import 'package:mercado_list/features/categoria/model/categoria_model.dart';
import 'package:mercado_list/features/categoria/repository/categoria_repository.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/itens_recorrentes/mapper/item_recorrente_mapper.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/repository/item_recorrente_repository.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';

void main() {
  group('CategoriasController.carregar', () {
    test('combina categorias e itens fornecidos pelos seus Services', () async {
      final categorias = [
        _categoria(id: 1, titulo: 'Limpeza'),
        _categoria(id: 2, titulo: 'Outros', categoriaPadrao: true),
      ];
      final itens = [
        _item(id: 10, idCategoria: 1, titulo: 'Detergente'),
        _item(id: 11, idCategoria: 2, titulo: 'Gelo'),
      ];
      final controller = CategoriasController(
        BancoLocal.instancia,
        _CategoriasServiceFake(categorias: categorias),
        _ItemRecorrenteServiceFake(itens: itens),
      );

      await controller.carregar();

      expect(controller.estado, EstadoDeTela.carregadaComDados);
      expect(controller.categoriasComItensRecorrentes, hasLength(2));
      expect(
        controller.categoriasComItensRecorrentes.first.itensRecorrentes,
        [itens.first],
      );
      expect(
        controller.categoriasComItensRecorrentes.last.itensRecorrentes,
        [itens.last],
      );
    });

    test('define estado de erro quando um dos Services falha', () async {
      final controller = CategoriasController(
        BancoLocal.instancia,
        _CategoriasServiceFake(erro: StateError('falha simulada')),
        _ItemRecorrenteServiceFake(itens: const []),
      );

      await controller.carregar();

      expect(controller.estado, EstadoDeTela.erro);
      expect(controller.categoriasComItensRecorrentes, isEmpty);
    });
  });
}

Categoria _categoria({
  required int id,
  required String titulo,
  bool categoriaPadrao = false,
}) {
  return Categoria(
    id: id,
    titulo: titulo,
    cor: Cor.obterCor(cor: Cor.indigo),
    ordem: id,
    categoriaPadrao: categoriaPadrao,
  );
}

ItemRecorrente _item({
  required int id,
  required int idCategoria,
  required String titulo,
}) {
  return ItemRecorrente(
    id: id,
    idCategoria: idCategoria,
    titulo: titulo,
    tipoMedida: TipoMedida.und,
  );
}

class _CategoriasServiceFake extends CategoriasService {
  final List<Categoria> categorias;
  final Object? erro;

  _CategoriasServiceFake({this.categorias = const [], this.erro})
      : super(
          CategoriasRepository(
            bancoLocal: BancoLocal.instancia,
            categoriaMapper: CategoriaMapper(),
          ),
        );

  @override
  Future<List<Categoria>> recuperarTodos() async {
    if (erro != null) {
      throw erro!;
    }
    return categorias;
  }
}

class _ItemRecorrenteServiceFake extends ItemRecorrenteService {
  final List<ItemRecorrente> itens;

  _ItemRecorrenteServiceFake({required this.itens})
      : super(
          ItemRecorrenteRepository(
            bancoLocal: BancoLocal.instancia,
            itemRecorrenteMapper: ItemRecorrenteMapper(),
          ),
        );

  @override
  Future<List<ItemRecorrente>> recuperarTodos() async => itens;
}

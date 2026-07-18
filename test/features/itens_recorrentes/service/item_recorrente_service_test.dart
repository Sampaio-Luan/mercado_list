import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/core/database/banco_local.dart';
import 'package:mercado_list/features/itens_recorrentes/mapper/item_recorrente_mapper.dart';
import 'package:mercado_list/features/itens_recorrentes/model/item_recorrente_model.dart';
import 'package:mercado_list/features/itens_recorrentes/repository/item_recorrente_repository.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';

void main() {
  test('recusa itens que não pertencem à categoria de origem', () async {
    final service = ItemRecorrenteService(
      ItemRecorrenteRepository(
        bancoLocal: BancoLocal.instancia,
        itemRecorrenteMapper: ItemRecorrenteMapper(),
      ),
    );
    final item = ItemRecorrente(
      id: 1,
      idCategoria: 3,
      titulo: 'Detergente',
      tipoMedida: TipoMedida.und,
    );

    await expectLater(
      service.moverParaCategoria(
        itens: [item],
        categoriaOrigem: 1,
        categoriaDestino: 2,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

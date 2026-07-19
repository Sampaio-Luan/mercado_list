import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/estado_de_tela.dart';
import 'package:mercado_list/features/categoria/controller/categorias_controller.dart';
import 'package:mercado_list/features/categoria/screen/categorias_screen.dart';
import 'package:mercado_list/features/categoria/service/categorias_service.dart';
import 'package:mercado_list/features/categoria/service/excluir_categoria_service.dart';
import 'package:mercado_list/features/itens_recorrentes/service/item_recorrente_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('aviso migra após 15 segundos e pode ser reexibido e dispensado',
      (
    tester,
  ) async {
    final controller = CategoriasController(
      _CategoriasServiceVazio(),
      _ItemRecorrenteServiceVazio(),
      _ExcluirCategoriaServiceVazio(),
    );
    addTearDown(controller.dispose);
    controller.estado = EstadoDeTela.carregadaSemDados;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: CategoriasScreen()),
      ),
    );

    expect(
      find.text('Pressione e arraste para reordenar'),
      findsOneWidget,
    );
    expect(find.byTooltip('Como reordenar categorias'), findsNothing);
    expect(find.byTooltip('Dispensar aviso'), findsNothing);
    expect(find.byTooltip('Ordenar categorias de A a Z'), findsOneWidget);

    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();

    expect(
      find.text('Pressione e arraste para reordenar'),
      findsNothing,
    );
    expect(find.byTooltip('Como reordenar categorias'), findsOneWidget);
    final botaoAviso = tester.widget<IconButton>(
      find.byKey(const ValueKey('acao-aviso-reordenacao')),
    );
    expect((botaoAviso.icon as Icon).color, isNotNull);

    await tester.tap(find.byTooltip('Como reordenar categorias'));
    await tester.pumpAndSettle();

    expect(
      find.text('Pressione e arraste para reordenar'),
      findsOneWidget,
    );
    expect(find.byTooltip('Como reordenar categorias'), findsOneWidget);
    expect(find.byTooltip('Dispensar aviso'), findsOneWidget);

    await tester.tap(find.byTooltip('Dispensar aviso'));
    await tester.pumpAndSettle();

    expect(
      find.text('Pressione e arraste para reordenar'),
      findsNothing,
    );
    expect(find.byTooltip('Como reordenar categorias'), findsOneWidget);
  });
}

class _CategoriasServiceVazio implements CategoriasServiceContract {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ItemRecorrenteServiceVazio implements ItemRecorrenteService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ExcluirCategoriaServiceVazio implements ExcluirCategoriaContract {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

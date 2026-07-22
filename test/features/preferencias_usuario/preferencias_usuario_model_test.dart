import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/preferencias_usuario/preferencias_usuario_model.dart';

void main() {
  test('copyWith permite limpar explicitamente a última lista aberta', () {
    final preferencias = PreferenciasUsuario.padrao().copyWith(
      ultimaListaAberta: 12,
    );

    expect(preferencias.copyWith().ultimaListaAberta, 12);
    expect(preferencias.copyWith(ultimaListaAberta: null).ultimaListaAberta,
        isNull);
  });
}

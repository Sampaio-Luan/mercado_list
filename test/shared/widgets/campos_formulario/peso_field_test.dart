import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/shared/widgets/campos_formulario/peso_field.dart';

void main() {
  test('formata peso em tempo real usando três casas decimais', () {
    final formatador = PesoInputFormatter();

    final primeiro = formatador.formatEditUpdate(
      const TextEditingValue(),
      const TextEditingValue(
        text: '1',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    final segundo = formatador.formatEditUpdate(
      primeiro,
      TextEditingValue(
        text: '${primeiro.text}2',
        selection: TextSelection.collapsed(offset: primeiro.text.length + 1),
      ),
    );

    expect(primeiro.text, '0,001');
    expect(segundo.text, '0,012');
    expect(PesoInputFormatter.gramasDoTexto('1,250'), 1250);
    expect(PesoInputFormatter.formatarGramas(1250), '1,250');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/extensions/cor_contraste_extension.dart';

void main() {
  final temaClaro = ThemeData.light().copyWith(
    colorScheme: ThemeData.light().colorScheme.copyWith(
          surface: Colors.white,
          onSurface: Colors.black,
        ),
  );
  final temaEscuro = ThemeData.dark().copyWith(
    colorScheme: ThemeData.dark().colorScheme.copyWith(
          surface: Colors.black,
          onSurface: Colors.white,
        ),
  );

  test('preserva a cor quando há contraste suficiente', () {
    expect(Colors.indigo.paraPrimeiroPlano(temaClaro), Colors.indigo);
    expect(Colors.amber.paraPrimeiroPlano(temaEscuro), Colors.amber);
  });

  test('usa onSurface quando a cor se confunde com o tema', () {
    expect(Colors.yellow.paraPrimeiroPlano(temaClaro), Colors.black);
    expect(Colors.indigo.paraPrimeiroPlano(temaEscuro), Colors.white);
  });

  test('seleciona preto ou branco com maior contraste sobre uma cor', () {
    expect(Colors.yellow.corSobre, Colors.black);
    expect(Colors.indigo.corSobre, Colors.white);
  });
}

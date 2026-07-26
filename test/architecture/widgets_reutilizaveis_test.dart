import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'UI de produção não é decomposta em métodos privados que retornam Widget',
      () {
    final ocorrencias = <String>[];
    final assinaturaMetodoWidget = RegExp(
      r'^\s*(?:Widget\??|List<\s*Widget\s*>|Iterable<\s*Widget\s*>)'
      r'\s+_[A-Za-z]\w*\s*\(',
      multiLine: true,
    );

    final arquivosDart = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((arquivo) => arquivo.path.endsWith('.dart'));

    for (final arquivo in arquivosDart) {
      final conteudo = arquivo.readAsStringSync();
      for (final correspondencia
          in assinaturaMetodoWidget.allMatches(conteudo)) {
        final linha = '\n'
                .allMatches(conteudo.substring(0, correspondencia.start))
                .length +
            1;
        ocorrencias.add('${arquivo.path}:$linha');
      }
    }

    expect(
      ocorrencias,
      isEmpty,
      reason: 'Extraia a composição para StatelessWidget/StatefulWidget ou '
          'mantenha-a diretamente no build. Builders exigidos por APIs do '
          'Flutter continuam permitidos.',
    );
  });
}

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/compartilhamento/controller/compartilhamento_controller.dart';
import 'package:mercado_list/features/compartilhamento/model/compartilhamento_model.dart';
import 'package:mercado_list/features/compartilhamento/service/compartilhamento_service.dart';
import 'package:mercado_list/features/compartilhamento/service/gerador_arquivo_compartilhamento.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  const conteudo = ConteudoCompartilhamento(
    contexto: ContextoCompartilhamento.itensDaLista,
    titulo: 'Mercado',
    itens: [
      ItemCompartilhamento(titulo: 'Arroz', marcado: true),
      ItemCompartilhamento(titulo: 'Feijão', marcado: false),
    ],
  );

  test('mantém título selecionado e permite escolher outros campos', () {
    final controller = CompartilhamentoController(
      conteudo,
      CompartilhamentoService(),
    );

    controller.alternarCampo(CampoCompartilhamento.titulo);
    controller.alternarCampo(CampoCompartilhamento.status);

    expect(controller.formato, FormatoCompartilhamento.texto);
    expect(
      controller.camposSelecionados,
      containsAll([
        CampoCompartilhamento.titulo,
        CampoCompartilhamento.status,
      ]),
    );
  });

  test('envia ao compartilhador a configuração selecionada', () async {
    final compartilhador = _CompartilhadorFake();
    final gerador = _GeradorFake();
    final controller = CompartilhamentoController(
      conteudo,
      CompartilhamentoService(
        compartilhador: compartilhador,
        geradores: [gerador],
      ),
    );
    controller.selecionarEscopo(EscopoCompartilhamento.pendentes);
    controller.selecionarFormato(FormatoCompartilhamento.json);

    final resultado = await controller.compartilhar();

    expect(resultado, ShareResultStatus.success);
    expect(gerador.configuracao?.escopo, EscopoCompartilhamento.pendentes);
    expect(compartilhador.arquivos.single.nome, 'lista.json');
    expect(compartilhador.texto, contains('Mercado List'));
  });

  test('formato texto compartilha mensagem sem criar anexo', () async {
    final compartilhador = _CompartilhadorFake();
    final controller = CompartilhamentoController(
      conteudo,
      CompartilhamentoService(
        compartilhador: compartilhador,
        geradores: [GeradorTextoCompartilhamento()],
      ),
    );
    controller.alternarCampo(CampoCompartilhamento.status);

    final resultado = await controller.compartilhar();

    expect(resultado, ShareResultStatus.success);
    expect(compartilhador.arquivos, isEmpty);
    expect(compartilhador.texto, contains('1. Arroz ✅'));
    expect(compartilhador.texto, contains('2. Feijão\n'));
    expect(compartilhador.texto, isNot(contains('Status:')));
    expect(compartilhador.texto, contains('Baixe o app:'));
  });
}

class _GeradorFake implements GeradorArquivoCompartilhamento {
  ConfiguracaoCompartilhamento? configuracao;

  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.json;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    this.configuracao = configuracao;
    return const [
      ArquivoCompartilhamento(
        nome: 'lista.json',
        mimeType: 'application/json',
        bytes: [123, 125],
      ),
    ];
  }
}

class _CompartilhadorFake implements CompartilhadorArquivosContract {
  List<ArquivoCompartilhamento> arquivos = [];
  String? texto;

  @override
  Future<ShareResultStatus> compartilhar({
    required String titulo,
    required List<ArquivoCompartilhamento> arquivos,
    required String texto,
    Rect? origem,
  }) async {
    this.arquivos = arquivos;
    this.texto = texto;
    return ShareResultStatus.success;
  }
}

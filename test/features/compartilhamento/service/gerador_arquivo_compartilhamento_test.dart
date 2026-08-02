import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:csv/csv.dart' as csv_lib;
import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/compartilhamento/model/compartilhamento_model.dart';
import 'package:mercado_list/features/compartilhamento/service/gerador_arquivo_compartilhamento.dart';

void main() {
  final configuracao = ConfiguracaoCompartilhamento(
    conteudo: const ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.lista,
      titulo: 'Feira do mês',
      descricao: 'Compra principal',
      orcamento: 10000,
      itens: [
        ItemCompartilhamento(
          titulo: 'Café',
          categoria: 'Mercearia',
          quantidade: 2,
          unidade: 'und',
          preco: 1250,
          total: 2500,
          marcado: true,
        ),
        ItemCompartilhamento(
          titulo: 'Pão',
          categoria: 'Padaria',
          marcado: false,
        ),
      ],
    ),
    escopo: EscopoCompartilhamento.marcados,
    campos: const {
      CampoCompartilhamento.titulo,
      CampoCompartilhamento.categoria,
      CampoCompartilhamento.preco,
      CampoCompartilhamento.status,
    },
    formato: FormatoCompartilhamento.json,
  );

  test('JSON mantém tipos e inclui somente escopo e campos escolhidos',
      () async {
    final arquivo =
        (await GeradorJsonCompartilhamento().gerar(configuracao)).single;
    final json = jsonDecode(utf8.decode(arquivo.bytes)) as Map<String, dynamic>;
    final itens = json['itens'] as List<dynamic>;

    expect(arquivo.nome, 'feira_do_mês_marcados.json');
    expect(itens, hasLength(1));
    expect(itens.single['titulo'], 'Café');
    expect(itens.single['preco_centavos'], 1250);
    expect(itens.single['marcado'], isTrue);
    expect(itens.single.containsKey('quantidade'), isFalse);
  });

  test('CSV é compatível com Excel e preserva acentos', () async {
    final arquivo =
        (await GeradorCsvCompartilhamento().gerar(configuracao)).single;
    final texto = utf8.decode(arquivo.bytes);

    expect(arquivo.bytes.take(3), [0xEF, 0xBB, 0xBF]);
    expect(texto, contains('Título;Categoria;Preço;Status'));
    expect(texto, contains('Café;Mercearia;'));
    expect(texto, isNot(contains('Pão')));
  });

  test('CSV preserva emojis e formata o Real sem espaço especial', () async {
    final configuracaoUnicode = ConfiguracaoCompartilhamento(
      conteudo: const ConteudoCompartilhamento(
        contexto: ContextoCompartilhamento.lista,
        titulo: 'Compras 🛒',
        itens: [
          ItemCompartilhamento(
            titulo: 'Café ☕',
            preco: 1250,
            marcado: true,
          ),
        ],
      ),
      escopo: EscopoCompartilhamento.todos,
      campos: const {
        CampoCompartilhamento.titulo,
        CampoCompartilhamento.preco,
        CampoCompartilhamento.status,
      },
      formato: FormatoCompartilhamento.csv,
    );
    final arquivo = (await GeradorCsvCompartilhamento().gerar(
      configuracaoUnicode,
    ))
        .single;
    final linhas = csv_lib.excel.decode(utf8.decode(arquivo.bytes));

    expect(arquivo.mimeType, 'text/csv; charset=utf-8');
    expect(linhas[1], ['Café ☕', r'R$ 12,50', 'Marcado']);
    expect(utf8.decode(arquivo.bytes), isNot(contains('\u00A0')));
  });

  test('CSV neutraliza conteúdo que poderia ser executado como fórmula',
      () async {
    final configuracaoInsegura = ConfiguracaoCompartilhamento(
      conteudo: const ConteudoCompartilhamento(
        contexto: ContextoCompartilhamento.lista,
        titulo: 'Lista',
        itens: [ItemCompartilhamento(titulo: '=1+1')],
      ),
      escopo: EscopoCompartilhamento.todos,
      campos: const {CampoCompartilhamento.titulo},
      formato: FormatoCompartilhamento.csv,
    );

    final arquivo = (await GeradorCsvCompartilhamento().gerar(
      configuracaoInsegura,
    ))
        .single;

    expect(utf8.decode(arquivo.bytes), contains("'=1+1"));
  });

  test('Excel cria uma planilha válida com cabeçalho e dados', () async {
    final arquivo =
        (await GeradorExcelCompartilhamento().gerar(configuracao)).single;
    final pasta = excel_lib.Excel.decodeBytes(arquivo.bytes);
    final planilha = pasta.tables['Itens']!;

    expect(planilha.rows, hasLength(2));
    expect(planilha.rows.first.first?.value.toString(), 'Título');
    expect(planilha.rows[1].first?.value.toString(), 'Café');
  });

  test('PDF gera documento válido com os dados filtrados', () async {
    final arquivo =
        (await GeradorPdfCompartilhamento().gerar(configuracao)).single;

    expect(arquivo.bytes, isNotEmpty);
    expect(ascii.decode(arquivo.bytes.take(4).toList()), '%PDF');
  });

  test('imagem renderiza os itens abaixo do cabeçalho', () async {
    final arquivo =
        (await GeradorImagemCompartilhamento().gerar(configuracao)).single;
    final codec = await ui.instantiateImageCodec(
      Uint8List.fromList(arquivo.bytes),
    );
    final frame = await codec.getNextFrame();
    final pixels = await frame.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );

    expect(arquivo.mimeType, 'image/png');
    expect(frame.image.width, 1080);
    expect(frame.image.height, greaterThan(400));
    expect(
      _possuiPixelDeTextoNosItens(
        pixels!,
        largura: frame.image.width,
        altura: frame.image.height,
      ),
      isTrue,
    );
    frame.image.dispose();
    codec.dispose();
  });
}

bool _possuiPixelDeTextoNosItens(
  ByteData pixels, {
  required int largura,
  required int altura,
}) {
  for (var y = 270; y < altura; y += 2) {
    for (var x = 70; x < largura - 70; x += 2) {
      final indice = (y * largura + x) * 4;
      final vermelho = pixels.getUint8(indice);
      final verde = pixels.getUint8(indice + 1);
      final azul = pixels.getUint8(indice + 2);
      if (vermelho < 100 && verde < 100 && azul < 100) return true;
    }
  }
  return false;
}

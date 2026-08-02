import 'dart:convert';

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
}

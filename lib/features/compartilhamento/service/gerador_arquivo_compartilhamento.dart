import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart' as csv_lib;
import 'package:excel/excel.dart' as excel_lib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/monetario_utils.dart';
import '../model/compartilhamento_model.dart';
import 'tabela_compartilhamento.dart';

abstract interface class GeradorArquivoCompartilhamento {
  FormatoCompartilhamento get formato;

  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  );
}

class GeradorJsonCompartilhamento implements GeradorArquivoCompartilhamento {
  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.json;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final dados = <String, Object?>{
      'titulo': tabela.conteudo.titulo,
      if (tabela.conteudo.descricao?.trim().isNotEmpty == true)
        'descricao': tabela.conteudo.descricao,
      if (tabela.conteudo.data != null)
        'data': tabela.conteudo.data!.toUtc().toIso8601String(),
      if (tabela.conteudo.orcamento != null)
        'orcamento_centavos': tabela.conteudo.orcamento,
      'escopo': tabela.escopo.name,
      'itens': tabela.itens
          .map(
            (item) => {
              for (final campo in tabela.campos)
                tabela.chaveJson(campo): tabela.valorJson(item, campo),
            },
          )
          .toList(growable: false),
    };
    final conteudo = const JsonEncoder.withIndent('  ').convert(dados);
    return [
      ArquivoCompartilhamento(
        nome: '${_nomeBase(tabela)}.json',
        mimeType: formato.mimeType,
        bytes: utf8.encode(conteudo),
      ),
    ];
  }
}

class GeradorCsvCompartilhamento implements GeradorArquivoCompartilhamento {
  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.csv;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final linhas = <List<dynamic>>[
      tabela.cabecalhos,
      ...tabela.linhas.map(
        (linha) => linha.map(_protegerCelulaCsv).toList(growable: false),
      ),
    ];
    final conteudo = csv_lib.Csv(
      fieldDelimiter: ';',
      lineDelimiter: '\r\n',
    ).encode(linhas);
    return [
      ArquivoCompartilhamento(
        nome: '${_nomeBase(tabela)}.csv',
        mimeType: formato.mimeType,
        bytes: utf8.encode('\ufeff$conteudo'),
      ),
    ];
  }
}

class GeradorExcelCompartilhamento implements GeradorArquivoCompartilhamento {
  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.excel;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final pasta = excel_lib.Excel.createExcel();
    final planilha = pasta['Itens'];
    pasta.setDefaultSheet('Itens');
    pasta.delete('Sheet1');
    planilha.appendRow(
      tabela.cabecalhos.map(excel_lib.TextCellValue.new).toList(),
    );
    for (final linha in tabela.linhas) {
      planilha.appendRow(linha.map(excel_lib.TextCellValue.new).toList());
    }
    final bytes = pasta.save();
    if (bytes == null) {
      throw StateError('Não foi possível gerar a planilha.');
    }
    return [
      ArquivoCompartilhamento(
        nome: '${_nomeBase(tabela)}.xlsx',
        mimeType: formato.mimeType,
        bytes: bytes,
      ),
    ];
  }
}

class GeradorPdfCompartilhamento implements GeradorArquivoCompartilhamento {
  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.pdf;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final bytes = await gerarBytes(tabela);
    return [
      ArquivoCompartilhamento(
        nome: '${_nomeBase(tabela)}.pdf',
        mimeType: formato.mimeType,
        bytes: bytes,
      ),
    ];
  }

  Future<Uint8List> gerarBytes(TabelaCompartilhamento tabela) async {
    final documento = pw.Document(
      title: tabela.conteudo.titulo,
      author: 'Mercado List',
    );
    documento.addPage(
      pw.MultiPage(
        pageFormat: tabela.campos.length > 5
            ? PdfPageFormat.a4.landscape
            : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            tabela.conteudo.titulo,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          if (tabela.conteudo.descricao?.trim().isNotEmpty == true) ...[
            pw.SizedBox(height: 4),
            pw.Text(tabela.conteudo.descricao!),
          ],
          pw.SizedBox(height: 8),
          pw.Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              pw.Text('Escopo: ${tabela.escopo.rotulo}'),
              pw.Text('Itens: ${tabela.itens.length}'),
              if (tabela.dataFormatada.isNotEmpty)
                pw.Text('Data: ${tabela.dataFormatada}'),
              if (tabela.conteudo.orcamento != null)
                pw.Text(
                  'Orçamento: ${MonetarioUtils.formatarIntToMoeda(tabela.conteudo.orcamento!)}',
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: tabela.cabecalhos,
            data: tabela.linhas,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding: const pw.EdgeInsets.all(5),
            border: pw.TableBorder.all(color: PdfColors.grey500, width: .5),
          ),
        ],
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
      ),
    );
    return documento.save();
  }
}

class GeradorImagemCompartilhamento implements GeradorArquivoCompartilhamento {
  GeradorImagemCompartilhamento({GeradorPdfCompartilhamento? geradorPdf})
      : _geradorPdf = geradorPdf ?? GeradorPdfCompartilhamento();

  final GeradorPdfCompartilhamento _geradorPdf;

  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.imagem;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final pdf = await _geradorPdf.gerarBytes(tabela);
    final arquivos = <ArquivoCompartilhamento>[];
    var pagina = 1;
    await for (final raster in Printing.raster(pdf, dpi: 144)) {
      arquivos.add(
        ArquivoCompartilhamento(
          nome: '${_nomeBase(tabela)}_${pagina.toString().padLeft(2, '0')}.png',
          mimeType: formato.mimeType,
          bytes: await raster.toPng(),
        ),
      );
      pagina++;
    }
    if (arquivos.isEmpty) {
      throw StateError('Não foi possível gerar a imagem.');
    }
    return arquivos;
  }
}

String _nomeBase(TabelaCompartilhamento tabela) {
  final titulo = tabela.conteudo.titulo
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9áàâãéèêíïóôõöúçñ]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return '${titulo.isEmpty ? 'lista' : titulo}_${tabela.escopo.name}';
}

String _protegerCelulaCsv(String valor) {
  return RegExp(r'^[=+\-@\t\r]').hasMatch(valor) ? "'$valor" : valor;
}

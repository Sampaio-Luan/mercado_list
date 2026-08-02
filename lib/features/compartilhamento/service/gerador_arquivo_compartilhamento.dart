import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:csv/csv.dart' as csv_lib;
import 'package:excel/excel.dart' as excel_lib;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/monetario_utils.dart';
import '../model/compartilhamento_model.dart';
import '../model/identidade_compartilhamento.dart';
import 'tabela_compartilhamento.dart';

abstract interface class GeradorArquivoCompartilhamento {
  FormatoCompartilhamento get formato;

  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  );
}

class GeradorTextoCompartilhamento implements GeradorArquivoCompartilhamento {
  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.texto;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final texto = StringBuffer()
      ..writeln(tabela.conteudo.titulo)
      ..writeln('Escopo: ${tabela.escopo.rotulo}');
    if (tabela.conteudo.descricao?.trim().isNotEmpty == true) {
      texto.writeln(tabela.conteudo.descricao!.trim());
    }
    for (final item in tabela.itens) {
      texto.writeln('\n• ${item.titulo}');
      for (final campo in tabela.campos) {
        if (campo == CampoCompartilhamento.titulo) continue;
        final valor = tabela.valorFormatado(item, campo);
        if (valor.isNotEmpty) texto.writeln('  ${campo.rotulo}: $valor');
      }
    }
    texto
      ..writeln()
      ..write(IdentidadeCompartilhamento.mensagem);
    return [
      ArquivoCompartilhamento(
        nome: '${_nomeBase(tabela)}.txt',
        mimeType: formato.mimeType,
        bytes: utf8.encode(texto.toString()),
      ),
    ];
  }
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
      'mensagem_compartilhamento': IdentidadeCompartilhamento.mensagem,
      'compartilhado_pelo_app': IdentidadeCompartilhamento.nomeApp,
      'link_para_baixar': IdentidadeCompartilhamento.linkDownload,
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
      const [],
      [IdentidadeCompartilhamento.rodape],
    ];
    final conteudo = csv_lib.excel.encode(linhas);
    return [
      ArquivoCompartilhamento(
        nome: '${_nomeBase(tabela)}.csv',
        mimeType: formato.mimeType,
        bytes: utf8.encode(conteudo),
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
    planilha.appendRow([
      excel_lib.TextCellValue(IdentidadeCompartilhamento.rodape),
    ]);
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
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.UrlLink(
              destination: IdentidadeCompartilhamento.linkDownload,
              child: pw.Text(
                IdentidadeCompartilhamento.rodape,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.blue700,
                ),
              ),
            ),
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
    return documento.save();
  }
}

class GeradorImagemCompartilhamento implements GeradorArquivoCompartilhamento {
  @override
  FormatoCompartilhamento get formato => FormatoCompartilhamento.imagem;

  @override
  Future<List<ArquivoCompartilhamento>> gerar(
    ConfiguracaoCompartilhamento configuracao,
  ) async {
    final tabela = TabelaCompartilhamento(configuracao);
    final paginas = _paginarImagem(tabela);
    final arquivos = <ArquivoCompartilhamento>[];
    for (var indice = 0; indice < paginas.length; indice++) {
      final bytes = await _renderizarPaginaImagem(
        tabela,
        paginas[indice],
        numeroPagina: indice + 1,
        totalPaginas: paginas.length,
      );
      arquivos.add(
        ArquivoCompartilhamento(
          nome:
              '${_nomeBase(tabela)}_${(indice + 1).toString().padLeft(2, '0')}.png',
          mimeType: formato.mimeType,
          bytes: bytes,
        ),
      );
    }
    return arquivos;
  }

  List<List<_BlocoItemImagem>> _paginarImagem(
    TabelaCompartilhamento tabela,
  ) {
    const alturaDisponivel = 1580.0;
    const espacamento = 18.0;
    final paginas = <List<_BlocoItemImagem>>[];
    var paginaAtual = <_BlocoItemImagem>[];
    var alturaUsada = 0.0;

    for (final item in tabela.itens) {
      final bloco = _criarBlocoItemImagem(tabela, item);
      final alturaAdicional =
          bloco.altura + (paginaAtual.isEmpty ? 0 : espacamento);
      if (paginaAtual.isNotEmpty &&
          alturaUsada + alturaAdicional > alturaDisponivel) {
        paginas.add(paginaAtual);
        paginaAtual = [];
        alturaUsada = 0;
      }
      paginaAtual.add(bloco);
      alturaUsada += bloco.altura + (paginaAtual.length == 1 ? 0 : espacamento);
    }
    if (paginaAtual.isNotEmpty) paginas.add(paginaAtual);
    return paginas;
  }

  _BlocoItemImagem _criarBlocoItemImagem(
    TabelaCompartilhamento tabela,
    ItemCompartilhamento item,
  ) {
    final construtor = ui.ParagraphBuilder(
      ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
    )..pushStyle(
        ui.TextStyle(
          color: const ui.Color(0xFF1C1B1F),
          fontSize: 32,
          fontWeight: ui.FontWeight.w700,
        ),
      );
    construtor.addText(item.titulo);
    construtor.pop();
    construtor.pushStyle(
      ui.TextStyle(color: const ui.Color(0xFF49454F), fontSize: 24),
    );
    for (final campo in tabela.campos) {
      if (campo == CampoCompartilhamento.titulo) continue;
      final valor = tabela.valorFormatado(item, campo);
      if (valor.isNotEmpty) construtor.addText('\n${campo.rotulo}: $valor');
    }
    final paragrafo = construtor.build()
      ..layout(const ui.ParagraphConstraints(width: 920));
    return _BlocoItemImagem(paragrafo, paragrafo.height + 40);
  }

  Future<Uint8List> _renderizarPaginaImagem(
    TabelaCompartilhamento tabela,
    List<_BlocoItemImagem> blocos, {
    required int numeroPagina,
    required int totalPaginas,
  }) async {
    const largura = 1080;
    const margem = 48.0;
    const inicioItens = 250.0;
    const espacamento = 18.0;
    final alturaItens = blocos.fold<double>(
      0,
      (total, bloco) => total + bloco.altura,
    );
    final altura = (inicioItens +
            alturaItens +
            espacamento * (blocos.length - 1).clamp(0, blocos.length) +
            110)
        .ceil()
        .clamp(480, 8192);
    final gravador = ui.PictureRecorder();
    final canvas = ui.Canvas(gravador);
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, largura.toDouble(), altura.toDouble()),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, 14, altura.toDouble()),
      ui.Paint()..color = const ui.Color(0xFF6750A4),
    );

    final titulo = _criarParagrafoImagem(
      tabela.conteudo.titulo,
      tamanho: 46,
      peso: ui.FontWeight.w700,
      largura: largura - margem * 2,
    );
    canvas.drawParagraph(titulo, const ui.Offset(margem, 42));
    final subtitulo = _criarParagrafoImagem(
      '${tabela.escopo.rotulo} • ${tabela.itens.length} itens'
      '${totalPaginas > 1 ? ' • $numeroPagina/$totalPaginas' : ''}',
      tamanho: 25,
      cor: const ui.Color(0xFF49454F),
      largura: largura - margem * 2,
    );
    canvas.drawParagraph(
      subtitulo,
      ui.Offset(margem, 58 + titulo.height),
    );

    var topo = inicioItens;
    for (final bloco in blocos) {
      final area = ui.RRect.fromRectAndRadius(
        ui.Rect.fromLTWH(margem, topo, largura - margem * 2, bloco.altura),
        const ui.Radius.circular(20),
      );
      canvas.drawRRect(
        area,
        ui.Paint()..color = const ui.Color(0xFFF4F0F7),
      );
      canvas.drawParagraph(
        bloco.paragrafo,
        ui.Offset(margem + 28, topo + 20),
      );
      topo += bloco.altura + espacamento;
    }
    final rodape = _criarParagrafoImagem(
      IdentidadeCompartilhamento.rodape,
      tamanho: 19,
      cor: const ui.Color(0xFF4F378B),
      largura: largura - margem * 2,
    );
    canvas.drawParagraph(rodape, ui.Offset(margem, topo + 10));

    final desenho = gravador.endRecording();
    final imagem = await desenho.toImage(largura, altura);
    final dados = await imagem.toByteData(format: ui.ImageByteFormat.png);
    imagem.dispose();
    desenho.dispose();
    titulo.dispose();
    subtitulo.dispose();
    rodape.dispose();
    for (final bloco in blocos) {
      bloco.paragrafo.dispose();
    }
    if (dados == null) {
      throw StateError('Não foi possível gerar a imagem.');
    }
    return dados.buffer.asUint8List(dados.offsetInBytes, dados.lengthInBytes);
  }

  ui.Paragraph _criarParagrafoImagem(
    String texto, {
    required double tamanho,
    required double largura,
    ui.FontWeight peso = ui.FontWeight.w400,
    ui.Color cor = const ui.Color(0xFF1C1B1F),
  }) {
    final construtor = ui.ParagraphBuilder(
      ui.ParagraphStyle(textDirection: ui.TextDirection.ltr),
    )..pushStyle(ui.TextStyle(color: cor, fontSize: tamanho, fontWeight: peso));
    construtor.addText(texto);
    return construtor.build()..layout(ui.ParagraphConstraints(width: largura));
  }
}

class _BlocoItemImagem {
  const _BlocoItemImagem(this.paragrafo, this.altura);

  final ui.Paragraph paragrafo;
  final double altura;
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

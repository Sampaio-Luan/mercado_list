import 'dart:io';
import 'dart:ui';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../model/compartilhamento_model.dart';
import 'gerador_arquivo_compartilhamento.dart';

abstract interface class CompartilhadorArquivosContract {
  Future<ShareResultStatus> compartilhar({
    required String titulo,
    required List<ArquivoCompartilhamento> arquivos,
    Rect? origem,
  });
}

class SharePlusCompartilhador implements CompartilhadorArquivosContract {
  @override
  Future<ShareResultStatus> compartilhar({
    required String titulo,
    required List<ArquivoCompartilhamento> arquivos,
    Rect? origem,
  }) async {
    final temporario = await getTemporaryDirectory();
    final diretorio = Directory(
      path.join(temporario.path, 'mercado_list_compartilhamento'),
    );
    await diretorio.create(recursive: true);
    await _limparArquivosAnteriores(diretorio);
    final arquivosTemporarios = <File>[];

    for (final arquivo in arquivos) {
      final destino = File(path.join(diretorio.path, arquivo.nome));
      await destino.writeAsBytes(arquivo.bytes, flush: true);
      arquivosTemporarios.add(destino);
    }
    final resultado = await SharePlus.instance.share(
      ShareParams(
        title: titulo,
        subject: titulo,
        files: [
          for (var indice = 0; indice < arquivosTemporarios.length; indice++)
            XFile(
              arquivosTemporarios[indice].path,
              mimeType: arquivos[indice].mimeType,
            ),
        ],
        sharePositionOrigin: origem,
      ),
    );
    return resultado.status;
  }

  Future<void> _limparArquivosAnteriores(Directory diretorio) async {
    await for (final entidade in diretorio.list()) {
      if (entidade is File) await entidade.delete();
    }
  }
}

class CompartilhamentoService {
  CompartilhamentoService({
    CompartilhadorArquivosContract? compartilhador,
    List<GeradorArquivoCompartilhamento>? geradores,
  })  : _compartilhador = compartilhador ?? SharePlusCompartilhador(),
        _geradores = {
          for (final gerador in geradores ?? _geradoresPadrao)
            gerador.formato: gerador,
        };

  static final List<GeradorArquivoCompartilhamento> _geradoresPadrao = [
    GeradorImagemCompartilhamento(),
    GeradorPdfCompartilhamento(),
    GeradorCsvCompartilhamento(),
    GeradorExcelCompartilhamento(),
    GeradorJsonCompartilhamento(),
  ];

  final CompartilhadorArquivosContract _compartilhador;
  final Map<FormatoCompartilhamento, GeradorArquivoCompartilhamento> _geradores;

  Future<ShareResultStatus> compartilhar(
    ConfiguracaoCompartilhamento configuracao, {
    Rect? origem,
  }) async {
    if (configuracao.conteudo.itensNoEscopo(configuracao.escopo).isEmpty) {
      throw StateError('Não há itens nesse filtro para compartilhar.');
    }
    final gerador = _geradores[configuracao.formato];
    if (gerador == null) {
      throw UnsupportedError('Formato de compartilhamento não suportado.');
    }
    final arquivos = await gerador.gerar(configuracao);
    return _compartilhador.compartilhar(
      titulo: configuracao.conteudo.titulo,
      arquivos: arquivos,
      origem: origem,
    );
  }
}

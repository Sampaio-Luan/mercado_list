import 'package:intl/intl.dart';

import '../../../core/utils/monetario_utils.dart';
import '../model/compartilhamento_model.dart';

class TabelaCompartilhamento {
  TabelaCompartilhamento(ConfiguracaoCompartilhamento configuracao)
      : conteudo = configuracao.conteudo,
        escopo = configuracao.escopo,
        campos = CampoCompartilhamento.values
            .where(configuracao.campos.contains)
            .toList(growable: false),
        itens = configuracao.conteudo.itensNoEscopo(configuracao.escopo);

  final ConteudoCompartilhamento conteudo;
  final EscopoCompartilhamento escopo;
  final List<CampoCompartilhamento> campos;
  final List<ItemCompartilhamento> itens;

  List<String> get cabecalhos => campos.map((campo) => campo.rotulo).toList();

  List<List<String>> get linhas => itens
      .map(
        (item) => campos
            .map((campo) => valorFormatado(item, campo))
            .toList(growable: false),
      )
      .toList(growable: false);

  String valorFormatado(
    ItemCompartilhamento item,
    CampoCompartilhamento campo,
  ) {
    return switch (campo) {
      CampoCompartilhamento.titulo => item.titulo,
      CampoCompartilhamento.categoria => item.categoria ?? '',
      CampoCompartilhamento.quantidade => _formatarQuantidade(item),
      CampoCompartilhamento.unidade => item.unidade ?? '',
      CampoCompartilhamento.preco => _formatarMoeda(item.preco),
      CampoCompartilhamento.total => _formatarMoeda(item.total),
      CampoCompartilhamento.prioridade => item.prioridade ?? '',
      CampoCompartilhamento.observacao => item.observacao ?? '',
      CampoCompartilhamento.status => switch (item.marcado) {
          true => 'Marcado',
          false => 'Pendente',
          null => '',
        },
    };
  }

  Object? valorJson(
    ItemCompartilhamento item,
    CampoCompartilhamento campo,
  ) {
    return switch (campo) {
      CampoCompartilhamento.titulo => item.titulo,
      CampoCompartilhamento.categoria => item.categoria,
      CampoCompartilhamento.quantidade => item.quantidade,
      CampoCompartilhamento.unidade => item.unidade,
      CampoCompartilhamento.preco => item.preco,
      CampoCompartilhamento.total => item.total,
      CampoCompartilhamento.prioridade => item.prioridade,
      CampoCompartilhamento.observacao => item.observacao,
      CampoCompartilhamento.status => item.marcado,
    };
  }

  String chaveJson(CampoCompartilhamento campo) => switch (campo) {
        CampoCompartilhamento.titulo => 'titulo',
        CampoCompartilhamento.categoria => 'categoria',
        CampoCompartilhamento.quantidade => 'quantidade',
        CampoCompartilhamento.unidade => 'unidade',
        CampoCompartilhamento.preco => 'preco_centavos',
        CampoCompartilhamento.total => 'total_centavos',
        CampoCompartilhamento.prioridade => 'prioridade',
        CampoCompartilhamento.observacao => 'observacao',
        CampoCompartilhamento.status => 'marcado',
      };

  String get dataFormatada => conteudo.data == null
      ? ''
      : DateFormat('dd/MM/yyyy HH:mm', 'pt_BR')
          .format(conteudo.data!.toLocal());

  String _formatarQuantidade(ItemCompartilhamento item) {
    final quantidade = item.quantidade;
    if (quantidade == null) return '';
    if (item.unidade == 'kg') {
      return NumberFormat('0.000', 'pt_BR').format(quantidade / 1000);
    }
    return quantidade.toString();
  }

  String _formatarMoeda(int? valor) => valor == null
      ? ''
      : MonetarioUtils.formatarIntToMoeda(valor).replaceAll('\u00A0', ' ');
}

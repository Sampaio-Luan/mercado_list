import '../../itens/model/item_model.dart';
import '../../../core/model/progresso_operacao.dart';
import '../model/historico_model.dart';
import '../repository/historico_repository.dart';

abstract interface class SalvarHistoricoServiceContract {
  Future<Historico> executar({
    required Historico historico,
    required Iterable<Item> itens,
    required Map<int, String> titulosCategorias,
    AoProgredir? aoProgredir,
  });
}

class SalvarHistoricoService implements SalvarHistoricoServiceContract {
  final HistoricoRepositoryContract _repository;

  SalvarHistoricoService(this._repository);

  @override
  Future<Historico> executar({
    required Historico historico,
    required Iterable<Item> itens,
    required Map<int, String> titulosCategorias,
    AoProgredir? aoProgredir,
  }) async {
    final elegiveis = itens
        .where((item) => item.obtido && item.preco != null)
        .toList(growable: false);
    if (elegiveis.isEmpty) {
      throw StateError(
        'Marque ao menos um item e informe seu preço antes de salvar.',
      );
    }

    final totalEtapas = elegiveis.length + 4;
    await _informar(
      aoProgredir,
      1,
      totalEtapas,
      'Selecionando itens marcados com preço...',
    );
    await _informar(
      aoProgredir,
      2,
      totalEtapas,
      'Validando os dados da compra...',
    );
    final titulo = historico.titulo.trim();
    if (titulo.isEmpty) throw ArgumentError('O título é obrigatório.');
    final descricao = historico.descricao?.trim();
    final loja = historico.loja?.trim();
    final normalizado = historico.copia(
      titulo: titulo,
      descricao: descricao,
      limparDescricao: descricao?.isEmpty ?? true,
      loja: loja,
      limparLoja: loja?.isEmpty ?? true,
    );

    await _informar(
      aoProgredir,
      3,
      totalEtapas,
      'Criando o registro da compra...',
    );
    final salvo = await _repository.salvarCompra(
      historico: normalizado,
      itens: elegiveis,
      titulosCategorias: titulosCategorias,
      aoSalvarItem: aoProgredir == null
          ? null
          : (indice, total, titulo) async {
              await _informar(
                aoProgredir,
                indice + 3,
                totalEtapas,
                'Salvando item $indice de $total: $titulo',
              );
            },
    );
    await _informar(
      aoProgredir,
      totalEtapas,
      totalEtapas,
      'Finalizando e atualizando o histórico...',
    );
    return salvo;
  }

  Future<void> _informar(
    AoProgredir? aoProgredir,
    int etapa,
    int total,
    String descricao,
  ) async {
    if (aoProgredir == null) return;
    aoProgredir(
      ProgressoOperacao(etapa: etapa, total: total, descricao: descricao),
    );
    await Future<void>.delayed(Duration.zero);
  }
}

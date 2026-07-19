import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/shared/widgets/painel_pesquisa/painel_pesquisa_exportacoes.dart';

void main() {
  test('adicionar, editar e remover recalculam o filtro atual', () {
    final arroz = _Item(1, 'Arroz');
    final controlador = ControladorPainelPesquisa<_Item>(
      itens: [arroz, _Item(2, 'Feijão')],
      obterTextoPesquisa: (item) => item.nome,
      obterIdentificador: (item) => item.id,
      modoSelecao: ModoInteracaoPainel.semSelecao,
    );

    controlador.atualizarTermoPesquisa('arroz');
    expect(controlador.itensFiltrados, [arroz]);

    final arrozIntegral = _Item(3, 'Arroz integral');
    controlador.adicionarItem(arrozIntegral);
    expect(controlador.itensFiltrados, [arroz, arrozIntegral]);

    final macarrao = _Item(1, 'Macarrão');
    controlador.atualizarItem(arroz, macarrao);
    expect(controlador.itensFiltrados, [arrozIntegral]);

    controlador.removerItem(arrozIntegral);
    expect(controlador.itensFiltrados, isEmpty);
  });

  test('edição preserva a seleção usando o identificador estável', () {
    final original = _Item(1, 'Arroz');
    final controlador = ControladorPainelPesquisa<_Item>(
      itens: [original],
      obterTextoPesquisa: (item) => item.nome,
      obterIdentificador: (item) => item.id,
      modoSelecao: ModoInteracaoPainel.multipla,
    );

    controlador.alternarSelecaoItem(original);
    final editado = _Item(1, 'Arroz integral');
    controlador.atualizarItem(original, editado);

    expect(controlador.itemEstaSelecionado(editado), isTrue);
    expect(controlador.itensSelecionados, [editado]);
  });

  test('seleção múltipla alterna instâncias com o mesmo identificador', () {
    final original = _Item(1, 'Arroz');
    final controlador = ControladorPainelPesquisa<_Item>(
      itens: [original],
      obterTextoPesquisa: (item) => item.nome,
      obterIdentificador: (item) => item.id,
      modoSelecao: ModoInteracaoPainel.multipla,
    );

    controlador.alternarSelecaoItem(original);
    controlador.alternarSelecaoItem(_Item(1, 'Arroz integral'));

    expect(controlador.itensSelecionados, isEmpty);
  });
}

class _Item {
  final int id;
  final String nome;

  const _Item(this.id, this.nome);
}

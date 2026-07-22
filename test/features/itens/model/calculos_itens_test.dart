import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/constants/enums/tipo_medida.dart';
import 'package:mercado_list/features/itens/model/item_model.dart';
import 'package:mercado_list/features/itens/model/resumo_financeiro_itens.dart';

void main() {
  test('calcula total de unidade e peso sem usar ponto flutuante persistido',
      () {
    final unidade = Item(
      idLista: 1,
      idCategoria: 1,
      titulo: 'Leite',
      quantidade: 3,
      preco: 750,
    );
    final peso = Item(
      idLista: 1,
      idCategoria: 1,
      titulo: 'Banana',
      tipoMedida: TipoMedida.kg,
      quantidade: 1250,
      preco: 899,
    );

    expect(unidade.valorTotal, 2250);
    expect(peso.valorTotal, 1124);
  });

  test('resumo separa subtotal da lista e total dos itens marcados', () {
    final itens = [
      Item(
        idLista: 1,
        idCategoria: 1,
        titulo: 'A',
        quantidade: 2,
        preco: 1000,
      ),
      Item(
        idLista: 1,
        idCategoria: 1,
        titulo: 'B',
        quantidade: 1,
        preco: 500,
        obtido: true,
      ),
      Item(idLista: 1, idCategoria: 1, titulo: 'Sem preço'),
    ];

    final resumo = ResumoFinanceiroItens.calcular(itens);

    expect(resumo.possuiValor, isTrue);
    expect(resumo.subtotal, 2500);
    expect(resumo.totalMarcado, 500);
  });
}

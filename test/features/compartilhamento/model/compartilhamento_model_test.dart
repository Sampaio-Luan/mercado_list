import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/features/compartilhamento/model/compartilhamento_model.dart';

void main() {
  const itens = [
    ItemCompartilhamento(
      titulo: 'Arroz',
      categoria: 'Mercearia',
      quantidade: 2,
      unidade: 'und',
      preco: 850,
      total: 1700,
      prioridade: 'Alta',
      observacao: 'Integral',
      marcado: true,
    ),
    ItemCompartilhamento(titulo: 'Leite', marcado: false),
  ];

  test('separa todos, marcados e pendentes sem duplicar os itens', () {
    const conteudo = ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.itensDaLista,
      titulo: 'Mercado',
      itens: itens,
    );

    expect(conteudo.quantidadeNoEscopo(EscopoCompartilhamento.todos), 2);
    expect(conteudo.quantidadeNoEscopo(EscopoCompartilhamento.marcados), 1);
    expect(conteudo.quantidadeNoEscopo(EscopoCompartilhamento.pendentes), 1);
    expect(
      conteudo.itensNoEscopo(EscopoCompartilhamento.pendentes).single.titulo,
      'Leite',
    );
  });

  test('histórico disponibiliza somente o escopo pertinente', () {
    const conteudo = ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.historico,
      titulo: 'Compra',
      itens: itens,
    );

    expect(conteudo.escoposDisponiveis, [EscopoCompartilhamento.todos]);
  });

  test('título permanece obrigatório na configuração', () {
    const conteudo = ConteudoCompartilhamento(
      contexto: ContextoCompartilhamento.lista,
      titulo: 'Mercado',
      itens: itens,
    );
    final configuracao = ConfiguracaoCompartilhamento(
      conteudo: conteudo,
      escopo: EscopoCompartilhamento.todos,
      campos: const {CampoCompartilhamento.preco},
      formato: FormatoCompartilhamento.json,
    );

    expect(configuracao.campos, contains(CampoCompartilhamento.titulo));
    expect(configuracao.campos, contains(CampoCompartilhamento.preco));
  });
}

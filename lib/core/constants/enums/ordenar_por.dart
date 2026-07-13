enum OrdenarPor {
  nome,
  preco,
  prioridade,
  data;

  static String obterRotulo({required OrdenarPor tipo}) {
    switch (tipo) {
      case OrdenarPor.nome:
        return OrdenarPor.nome.name;
      case OrdenarPor.preco:
        return OrdenarPor.preco.name;
      case OrdenarPor.prioridade:
        return OrdenarPor.prioridade.name;
      case OrdenarPor.data:
        return OrdenarPor.data.name;
    }
  }

  static OrdenarPor obterPorRotulo({required String rotulo}) {
    switch (rotulo) {
      case 'nome':
        return OrdenarPor.nome;
      case 'preco':
        return OrdenarPor.preco;
      case 'prioridade':
        return OrdenarPor.prioridade;
      case 'data':
        return OrdenarPor.data;
      default:
        return OrdenarPor.nome;
    }
  }
}

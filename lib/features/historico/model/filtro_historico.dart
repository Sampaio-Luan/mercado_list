enum PeriodoHistorico {
  todos('Todos', null),
  seteDias('7 dias', 7),
  trintaDias('30 dias', 30),
  noventaDias('90 dias', 90);

  const PeriodoHistorico(this.rotulo, this.dias);

  final String rotulo;
  final int? dias;
}

enum OrdenacaoHistorico {
  maisRecentes('Mais recentes'),
  maisAntigos('Mais antigos'),
  maiorValor('Maior valor');

  const OrdenacaoHistorico(this.rotulo);

  final String rotulo;
}

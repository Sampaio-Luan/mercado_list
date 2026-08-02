enum ContextoCompartilhamento { itensDaLista, lista, historico }

enum EscopoCompartilhamento {
  todos('Todos'),
  marcados('Marcados'),
  pendentes('Pendentes');

  const EscopoCompartilhamento(this.rotulo);

  final String rotulo;
}

enum CampoCompartilhamento {
  titulo('Título'),
  categoria('Categoria'),
  quantidade('Quantidade'),
  unidade('Unidade'),
  preco('Preço'),
  total('Total'),
  prioridade('Prioridade'),
  observacao('Observação'),
  status('Status');

  const CampoCompartilhamento(this.rotulo);

  final String rotulo;
}

enum FormatoCompartilhamento {
  imagem('Imagem', 'png', 'image/png'),
  pdf('PDF', 'pdf', 'application/pdf'),
  csv('CSV', 'csv', 'text/csv'),
  excel(
    'Excel',
    'xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ),
  json('JSON', 'json', 'application/json');

  const FormatoCompartilhamento(this.rotulo, this.extensao, this.mimeType);

  final String rotulo;
  final String extensao;
  final String mimeType;
}

class ItemCompartilhamento {
  const ItemCompartilhamento({
    required this.titulo,
    this.categoria,
    this.quantidade,
    this.unidade,
    this.preco,
    this.total,
    this.prioridade,
    this.observacao,
    this.marcado,
  });

  final String titulo;
  final String? categoria;
  final int? quantidade;
  final String? unidade;
  final int? preco;
  final int? total;
  final String? prioridade;
  final String? observacao;
  final bool? marcado;
}

class ConteudoCompartilhamento {
  const ConteudoCompartilhamento({
    required this.contexto,
    required this.titulo,
    required this.itens,
    this.descricao,
    this.data,
    this.orcamento,
  });

  final ContextoCompartilhamento contexto;
  final String titulo;
  final String? descricao;
  final DateTime? data;
  final int? orcamento;
  final List<ItemCompartilhamento> itens;

  List<EscopoCompartilhamento> get escoposDisponiveis {
    if (contexto == ContextoCompartilhamento.historico) {
      return const [EscopoCompartilhamento.todos];
    }
    return EscopoCompartilhamento.values;
  }

  int quantidadeNoEscopo(EscopoCompartilhamento escopo) {
    return itensNoEscopo(escopo).length;
  }

  List<ItemCompartilhamento> itensNoEscopo(
    EscopoCompartilhamento escopo,
  ) {
    return switch (escopo) {
      EscopoCompartilhamento.todos => List.unmodifiable(itens),
      EscopoCompartilhamento.marcados => List.unmodifiable(
          itens.where((item) => item.marcado == true),
        ),
      EscopoCompartilhamento.pendentes => List.unmodifiable(
          itens.where((item) => item.marcado == false),
        ),
    };
  }

  Set<CampoCompartilhamento> get camposDisponiveis {
    final campos = <CampoCompartilhamento>{CampoCompartilhamento.titulo};
    bool possuiValor<T>(T? Function(ItemCompartilhamento item) leitor) =>
        itens.any((item) => leitor(item) != null);

    if (possuiValor((item) => item.categoria)) {
      campos.add(CampoCompartilhamento.categoria);
    }
    if (possuiValor((item) => item.quantidade)) {
      campos.add(CampoCompartilhamento.quantidade);
    }
    if (possuiValor((item) => item.unidade)) {
      campos.add(CampoCompartilhamento.unidade);
    }
    if (possuiValor((item) => item.preco)) {
      campos.add(CampoCompartilhamento.preco);
    }
    if (possuiValor((item) => item.total)) {
      campos.add(CampoCompartilhamento.total);
    }
    if (possuiValor((item) => item.prioridade)) {
      campos.add(CampoCompartilhamento.prioridade);
    }
    if (possuiValor((item) => item.observacao)) {
      campos.add(CampoCompartilhamento.observacao);
    }
    if (possuiValor((item) => item.marcado)) {
      campos.add(CampoCompartilhamento.status);
    }
    return campos;
  }
}

class ConfiguracaoCompartilhamento {
  ConfiguracaoCompartilhamento({
    required this.conteudo,
    required this.escopo,
    required Set<CampoCompartilhamento> campos,
    required this.formato,
  }) : campos = Set.unmodifiable({CampoCompartilhamento.titulo, ...campos});

  final ConteudoCompartilhamento conteudo;
  final EscopoCompartilhamento escopo;
  final Set<CampoCompartilhamento> campos;
  final FormatoCompartilhamento formato;
}

class ArquivoCompartilhamento {
  const ArquivoCompartilhamento({
    required this.nome,
    required this.mimeType,
    required this.bytes,
  });

  final String nome;
  final String mimeType;
  final List<int> bytes;
}

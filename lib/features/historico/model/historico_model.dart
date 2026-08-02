import 'package:flutter/material.dart';

import '../../../core/constants/enums/cor.dart';
import '../../../core/model/entidade_base.dart';

class Historico extends EntidadeBase {
  final String? descricao;
  final DateTime dataCompra;
  final Color cor;
  final int? orcamento;

  Historico({
    super.id,
    required super.titulo,
    this.descricao,
    required this.dataCompra,
    Color? cor,
    this.orcamento,
    super.dataCriacao,
    super.dataAlteracao,
    super.excluido,
  }) : cor = cor ?? Cor.obterCor(cor: Cor.indigo);

  Historico copia({
    String? titulo,
    String? descricao,
    bool limparDescricao = false,
    DateTime? dataCompra,
    Color? cor,
    int? orcamento,
    bool limparOrcamento = false,
    bool? excluido,
  }) {
    return Historico(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: limparDescricao ? null : (descricao ?? this.descricao),
      dataCompra: dataCompra ?? this.dataCompra,
      cor: cor ?? this.cor,
      orcamento: limparOrcamento ? null : (orcamento ?? this.orcamento),
      dataCriacao: dataCriacao,
      dataAlteracao: dataAlteracao,
      excluido: excluido ?? this.excluido,
    );
  }
}

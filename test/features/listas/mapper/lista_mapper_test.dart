import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_list/core/database/schema/tb_lista.dart';
import 'package:mercado_list/core/utils/data_utils.dart';
import 'package:mercado_list/features/listas/mapper/lista_mapper.dart';
import 'package:mercado_list/features/listas/model/lista_model.dart';

void main() {
  test('converte cor, orçamento opcional e fixação nos dois sentidos', () {
    final data = DateTime.utc(2026, 7, 19);
    final lista = Lista(
      id: 4,
      titulo: 'Mensal',
      cor: Colors.indigo,
      orcamento: null,
      ordem: 2,
      fixada: true,
      dataCriacao: data,
      dataAlteracao: data,
    );
    final mapper = ListaMapper();

    final mapa = mapper.paraMapa(lista);
    final restaurada = mapper.doMapa({
      ...mapa,
      TbLista.colunaDataCriacao: DataUtils.paraPersistencia(data),
      TbLista.colunaDataAlteracao: DataUtils.paraPersistencia(data),
    });

    expect(mapa[TbLista.colunaCor], 'indigo');
    expect(mapa[TbLista.colunaOrcamento], isNull);
    expect(mapa[TbLista.colunaFixada], 1);
    expect(restaurada.orcamento, isNull);
    expect(restaurada.fixada, isTrue);
    expect(restaurada.cor, Colors.indigo);
  });
}

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../data/repositories/lista.repository.dart';
import '../widgets/campos_formulario.dart/data_field.dart';

class ListaItensScreen extends StatelessWidget {
  const ListaItensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listaRepository = context.watch<ListaRepository>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      SizedBox(
        width: 300,
        child: DateField(
          rotulo: 'Data de Nascimento',
          color: Colors.red,
          initialDate: DateTime.now(),
          validators: [],
        ),
      ),
      Center(
        child: Text(
          listaRepository.listas.isEmpty
              ? 'Nenhuma Lista Criada'
              : 'Lista de Itens',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
    ]);
  }
}

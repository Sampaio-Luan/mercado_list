import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../data/repositories/lista.repository.dart';

class ListaItensScreen extends StatelessWidget {
  const ListaItensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listaRepository = context.watch<ListaRepository>();

    return Expanded(
      child: Container(
        color: Colors.indigo,
        child: Center(
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
      ),
    );
  }
}

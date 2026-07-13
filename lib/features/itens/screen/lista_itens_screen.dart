import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../listas/repository/lista_repository.dart';

class ListaItensScreen extends StatelessWidget {
  const ListaItensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listaRepository = context.watch<ListaRepository>();

    return listaRepository.listas.isEmpty
        ? const ListaVazia()
        : const ListaDeItens();
  }
}

class ListaVazia extends StatelessWidget {
  const ListaVazia({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        spacing: 25,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: Lottie.asset('lib/assets/lottie.json', fit: BoxFit.cover, height: MediaQuery.of(context).size.height * 0.45)),
          // Image.asset(
          //   'lib/assets/imagem2.webp',
          //   width: double.infinity,
          //   height: MediaQuery.of(context).size.height * 0.35,
          //   opacity: const AlwaysStoppedAnimation(0.8),
          //   color: Brightness.dark == Theme.of(context).brightness
          //       ? Colors.white.withAlpha(180)
          //       : Colors.blueGrey.withAlpha(180),
          //   colorBlendMode: BlendMode.srcIn,
          // ),
          Text(
            'Lista Vazia, adicione itens',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineMedium?.fontSize,
              // color: Brightness.dark == Theme.of(context).brightness
              //     ? Colors.white.withAlpha(180)
              //     : Colors.blueGrey.withAlpha(180),
            ),
          ),
        ]);
  }
}

class ListaDeItens extends StatelessWidget {
  const ListaDeItens({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Text('Lista de Itens'),
    );
  }
}

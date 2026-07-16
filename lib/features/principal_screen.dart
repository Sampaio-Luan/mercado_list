import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'itens/screen/lista_itens_screen.dart';
import 'listas/screen/lista_de_listas_screen.dart';
import 'preferencias_usuario/preferencias_provider.dart';

class PrincipalScreen extends StatelessWidget {
  const PrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasProvider>();
   // final listaProvider = context.read<ListaRepository>();
    // String titulo = preferencias.preferencias.ultimaListaAberta != null
    //     ? listaProvider.titulobyid(preferencias.preferencias.ultimaListaAberta!)
    //     : 'Mercado List';

    String titulo = 'Mercado List';
    return Scaffold(
      drawer: ListaDeListasScreen(),
      appBar: AppBar(
        title: Text(titulo),
        scrolledUnderElevation: 0,
        elevation: 0,
        
      ),
     // body: const TelaExemploBottomSheetPesquisa(), //
      body:const ListaItensScreen(),
    );
  }
}

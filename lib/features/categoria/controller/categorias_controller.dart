import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../core/constants/enums/estado_de_tela.dart';
import '../../../core/constants/logs/logs.dart';
import '../model/categoria_com_itens_recorrentes_model.dart';
import '../service/categorias_service.dart';

class CategoriasController extends ChangeNotifier {
  final CategoriasService categoriasService;

  CategoriasController({required this.categoriasService});

  EstadoDeTela estado = EstadoDeTela.carregando;
  List<CategoriaComItensRecorrentes> get categoriasComItensRecorrentes =>
    categoriasService.categoriasComItensRecorrentes;

  Future<void> carregar() async {
    estado = EstadoDeTela.carregando;
    notifyListeners();

    await categoriasService.carregar();

    if (categoriasService.categoriasComItensRecorrentes.isEmpty) {
      estado = EstadoDeTela.carregadaSemDados;
      notifyListeners();
    } else {
      estado = EstadoDeTela.carregadaComDados;
      notifyListeners();
    }

    log(
      name: LogId.categoriasController,
      'carregar(): finalizado, estado $estado',
    );
  }

  Future<void> reordenar(int oldIndex, int newIndex) async {
    await categoriasService.reordenar(oldIndex, newIndex);
    log(name: LogId.categoriasController, 'reordenar()');
    notifyListeners();
  }
}

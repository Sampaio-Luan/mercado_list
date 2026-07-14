import 'package:flutter/material.dart';

import '../../../core/constants/enums/estados_de_tela.dart';
import '../service/categorias_service.dart';

class CategoriasController extends ChangeNotifier{
  final String _log = '🟣🏷️CategoriasCotroller';
  final CategoriasService categoriasService;
  EstadoDeTela estado = EstadoDeTela.carregando;

  CategoriasController({required this.categoriasService});

}
import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../repository/itens_repository.dart';

class ItensService {
  final ItensRepository _repository;

  ItensService({required this._repository});

  Future<int> moverCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
  }) async {
    log(name: LogId.itemService, 'moverCategoria()');
    return 0;
  }

  Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) async {
    log(name: LogId.itemService, 'moverParaCategoria()');
    return await _repository.moverParaCategoria(
      categoriaOrigem: categoriaOrigem,
      categoriaDestino: categoriaDestino,
      databaseExecutor: databaseExecutor,
    );
  }
}

import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import '../../../core/constants/logs/logs.dart';
import '../repository/item_recorrente_repository.dart';

class ItensRecorrentesService {
  final ItemRecorrenteRepository _repository;

  ItensRecorrentesService({required this._repository});

  Future<int> moverParaCategoria({
    required int categoriaOrigem,
    required int categoriaDestino,
    DatabaseExecutor? databaseExecutor,
  }) async {
    log(name: LogId.itensRecorrentesService, 'moverParaCategoria()');
    return await _repository.moverParaCategoria(
      categoriaOrigem: categoriaOrigem,
      categoriaDestino: categoriaDestino,
      databaseExecutor: databaseExecutor,
    );
  }
}

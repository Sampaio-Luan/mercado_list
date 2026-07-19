import 'package:sqflite/sqflite.dart';

abstract interface class GerenciadorTransacoes {
  Future<T> executar<T>(
    Future<T> Function(DatabaseExecutor executor) operacao,
  );
}

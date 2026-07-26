import 'package:sqflite/sqflite.dart';

typedef ExecutorTransacao = DatabaseExecutor;

abstract interface class GerenciadorTransacoes {
  Future<T> executar<T>(
    Future<T> Function(ExecutorTransacao executor) operacao,
  );
}

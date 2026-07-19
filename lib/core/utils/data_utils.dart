import 'package:intl/intl.dart';

class DataUtils {
  DataUtils._();

  static final DateFormat _formatoBrasileiro = DateFormat('dd/MM/yyyy');
  static final DateFormat _formatoBrasileiroCompleto =
      DateFormat('dd/MM/yyyy HH:mm:ss.SSS');

  static DateTime agora() => DateTime.now();

  static DateTime agoraUtc() => DateTime.now().toUtc();

  static String paraPersistencia(DateTime data) {
    return data.toUtc().toIso8601String();
  }

  static DateTime daPersistencia(String valor) {
    final texto = valor.trim();
    final timestampSqliteSemFuso = RegExp(
      r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(?:\.\d+)?$',
    );
    if (timestampSqliteSemFuso.hasMatch(texto)) {
      return DateTime.parse('${texto.replaceFirst(' ', 'T')}Z');
    }
    return DateTime.parse(texto);
  }

  static DateTime paraHorarioLocal(DateTime data) => data.toLocal();

  static String formatarData(DateTime data) =>
      _formatoBrasileiro.format(paraHorarioLocal(data));

  static String formatarDataHora(DateTime data) =>
      _formatoBrasileiroCompleto.format(paraHorarioLocal(data));
}

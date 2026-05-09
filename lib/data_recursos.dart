import 'package:intl/intl.dart';

class RecursoDeData {
  static DateFormat formatoBrasileiro = DateFormat('dd/MM/yyyy');
  static DateFormat formatoBrasileiroCompleto =
      DateFormat('dd/MM/yyyy HH:mm:ss.SSS');
  static String dataParaStr({required DateTime data}) {
    return formatoBrasileiro.format(data);
  }

  static DateTime strParaData({required String strData}) {
    DateTime date = DateTime.parse(strData);
    return date;
  }

  static String dataFormatada(DateTime data) {
    return formatoBrasileiro.format(data);
  }
}

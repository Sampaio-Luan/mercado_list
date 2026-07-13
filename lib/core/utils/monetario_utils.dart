import 'package:intl/intl.dart';

class MonetarioUtils {
  static String formatarIntToMoeda(int v) {
    double valor = v / 100.0;
    final formatter = NumberFormat.simpleCurrency(locale: "pt_Br");
    String newText = formatter.format(valor);

    return newText;
  }

  static int deFormatadoParaInt({required String formatado}) {
    return int.parse(formatado.replaceAll(RegExp(r'[^0-9]'), ''));
  }

}

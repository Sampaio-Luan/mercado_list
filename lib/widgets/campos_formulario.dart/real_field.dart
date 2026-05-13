import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';

import '../../mixin/validacoes_mixin.dart';
import '../../utils/monetario_utils.dart';

class RealField extends StatelessWidget with ValidacoesMixin {
  final String rotulo;
  final int? valor;
  final Function(String) onChanged;
  final List<String? Function()> validadores;
  const RealField({
    super.key,
    required this.rotulo,
    required this.onChanged,
    this.valor,
    required this.validadores,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      initialValue:
          valor == null ? null : MonetarioUtils.formatarIntToMoeda(valor!),
      decoration: InputDecoration(
        labelText: rotulo,
      ),
      validator: validadores.isEmpty ? null : (value) => combo(validadores),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CurrencyInputFormatter(),
      ],
      onChanged: onChanged,
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    double value = double.parse(newValue.text);
    final formatter = NumberFormat.simpleCurrency(locale: "pt_Br");
    String newText = formatter.format(value / 100);
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

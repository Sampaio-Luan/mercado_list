import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PesoField extends StatelessWidget {
  final String rotulo;
  final int? valorEmGramas;
  final ValueChanged<int?> onChanged;

  const PesoField({
    super.key,
    this.rotulo = 'Peso',
    this.valorEmGramas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valorEmGramas == null
          ? null
          : PesoInputFormatter.formatarGramas(valorEmGramas!),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: '$rotulo (kg)'),
      inputFormatters: [PesoInputFormatter()],
      onChanged: (texto) {
        onChanged(PesoInputFormatter.gramasDoTexto(texto));
      },
    );
  }
}

class PesoInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatador = NumberFormat('0.000', 'pt_BR');

  static String formatarGramas(int gramas) {
    return _formatador.format(gramas / 1000);
  }

  static int? gramasDoTexto(String texto) {
    final digitos = texto.replaceAll(RegExp(r'[^0-9]'), '');
    return digitos.isEmpty ? null : int.parse(digitos);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final gramas = gramasDoTexto(newValue.text);
    if (gramas == null) return const TextEditingValue();
    final texto = formatarGramas(gramas);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

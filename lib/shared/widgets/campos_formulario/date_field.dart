import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/mixins/validacoes_mixin.dart';
import '../../../core/utils/data_utils.dart';


class DateField extends StatefulWidget {
  final String rotulo;
  final Color color;
  final DateTime initialDate;
  final List<String? Function()> validators;
  final void Function(DateTime d, BuildContext context) onPressed;

  const DateField({
    super.key,
    required this.rotulo,
    required this.color,
    required this.initialDate,
    required this.validators,
    required this.onPressed,
  });

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> with ValidacoesMixin {
  final TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.text = DataUtils.dataParaStr(data: widget.initialDate);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      //enabled: false,
      readOnly: true,
      onTap: () => _selectDate(context, widget.color),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.rotulo,
        prefixIcon: const Icon(Icons.calendar_month),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 2,
        ),
      ),
      validator: widget.validators.isEmpty
          ? null
          : (value) => combo(widget.validators),
    );
  }

  Future<void> _selectDate(BuildContext context, Color cor) async {
    final DateTime? picked = await showDatePicker(
        // helpText: widget.rotulo,
        //fieldLabelText: widget.rotulo,
        barrierDismissible: false,
        barrierColor: Theme.of(context).colorScheme.onSurface.withAlpha(50),
        locale: const Locale('pt', 'BR'),
        context: context,
        initialDate: widget.initialDate,
        firstDate: DateTime(2026, 1, 1),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: cor, // Cor do círculo e seleção
                onPrimary: Theme.of(context)
                    .colorScheme
                    .onPrimary, // Cor do texto sobre o primary
                onSurface: Colors.black87, // Cor dos números e meses
                surface: Theme.of(context)
                    .colorScheme
                    .surface, // Cor de fundo do calendário
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: cor, // Cor dos botões OK/Cancelar
                ),
              ),
            ),
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.57, // Sua largura personalizada
                width: MediaQuery.of(context).size.width * 0.9,
                child: child,
              ),
            ),
          );
        });

    if (picked != null) {
      setState(() {
        controller.text = DataUtils.dataParaStr(data: picked);

        widget.onPressed(picked, context);
      });
    }
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length >= newValue.text.length) {
      // Fix for backspace bug
      return newValue;
    }
    final dateText = _addSeparators(newValue.text, '/');
    return newValue.copyWith(
      text: dateText,
      selection: updateCursorPosition(dateText),
    );
  }

  String _addSeparators(String value, String separator) {
    value = value.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if (i == 1 || i == 3) {
        buffer.write(separator);
      }
    }
    return buffer.toString();
  }

  TextSelection updateCursorPosition(String text) {
    final cursorPosition = text.length;
    return TextSelection.collapsed(offset: cursorPosition);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../mixin/validacoes_mixin.dart';
import '../../utils/data_utils.dart';

class DateField extends StatefulWidget {
  final String rotulo;
  final Color color;
  final DateTime initialDate;
  final List<String? Function()> validators;
  final void Function(DateTime d, BuildContext context)? onPressed;

  const DateField({
    super.key,
    required this.rotulo,
    required this.color,
    required this.initialDate,
    required this.validators,
    this.onPressed,
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
      onTap: () => _selectDate(context),
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: widget.rotulo,
        suffixIcon: const Icon(Icons.calendar_month),
      ),
      validator: widget.validators.isEmpty
          ? null
          : (value) => combo(widget.validators),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDialog(
  context: context,
  builder: (context) => AlertDialog(
    //contentPadding: EdgeInsets.zero,
    content: SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Theme(
        data: ThemeData.light().copyWith(primaryColor: Colors.blue, ),
        child: CalendarDatePicker(
          initialDate: DateTime.now(),
          firstDate: DateTime(2026),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onDateChanged: (DateTime date) {
            // Aqui você pega a data selecionada
            Navigator.pop(context, date);
          },
        ),
      ),
    ),
  ),
);
    
    
    // showDatePicker(
    //   // helpText: widget.rotulo,
    //   //fieldLabelText: widget.rotulo,
    //   barrierDismissible: false ,
    //   barrierColor: Theme.of(context).colorScheme.onSurface.withAlpha(50),
    //   locale: const Locale('pt', 'BR'),
    //   context: context,
    //   initialDate: widget.initialDate,
    //   firstDate: DateTime(2026, 1, 1),
    //   lastDate: DateTime.now().add(const Duration(days: 365)),
    //   builder: (BuildContext context, Widget? child) {
    //     return Theme(
    //       data: Theme.of(context).copyWith(
    //         colorScheme: const ColorScheme.light(
    //           primary: Colors.deepPurple, // Cor do círculo e seleção
    //           onPrimary: Colors.white, // Cor do texto sobre o primary
    //           onSurface: Colors.black87, // Cor dos números e meses
    //         ),
    //         textButtonTheme: TextButtonThemeData(
    //           style: TextButton.styleFrom(
    //             foregroundColor:
    //                 Colors.deepPurple, // Cor dos botões OK/Cancelar
    //           ),
    //         ),
    //       ),
    //       child: Center(
    //         child: SizedBox(
    //           height: MediaQuery.of(context).size.height * 0.60,// Sua largura personalizada
    //           child: child,
    //         ),
    //       ),
    //     );

    //     // Transform.scale(
    //     //   scale: 0.85, // Diminui o datepicker para 90% do tamanho original
    //     //   child: child,
    //     // );
    //     // return Center(
    //     //   child: SizedBox(
    //     //     height: MediaQuery.of(context).size.height *
    //     //         0.55, // Define a largura desejada
    //     //     // height: 400, // Opcional: define a altura
    //     //     child: child,
    //     //   ),
    //     // );

    //     //   Theme(
    //     //   data: Theme.of(context).copyWith(
    //     //     colorScheme: const ColorScheme.light(
    //     //       primary: Colors.purple, // Cor do cabeçalho e selecionado
    //     //       onPrimary: Colors.white, // Cor do texto no cabeçalho
    //     //       surface: Colors.white, // Cor de fundo
    //     //       onSurface: Colors.black, // Cor do texto
    //     //     ),
    //     //     textButtonTheme: TextButtonThemeData(
    //     //       style: TextButton.styleFrom(
    //     //         foregroundColor: Colors.purple, // Cor dos botões CANCELAR/OK
    //     //       ),
    //     //     ),
    //     //   ),
    //     //   child: child!,
    //     // );
    //   },
    // );

    if (picked != null) {
      setState(() {
        controller.text = DataUtils.dataParaStr(data: picked);
        if (widget.onPressed != null) {
          widget.onPressed!(picked, context);
        }
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

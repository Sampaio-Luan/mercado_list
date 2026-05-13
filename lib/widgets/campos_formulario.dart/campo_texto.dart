import 'package:flutter/material.dart';

import '../../mixin/validacoes_mixin.dart';

class CampoDeTexto extends StatelessWidget with ValidacoesMixin {
  final String rotulo;
  final String valor;
  final List<String? Function()> validadores;
  final int? linhas;

  final void Function(String v)? onChanged;

  CampoDeTexto({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.validadores,
    this.linhas,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: TextEditingController(text: valor),
      maxLines: linhas ?? 1,
      maxLength: linhas != null ? 255 : null,
      decoration: InputDecoration(
        label: Text(rotulo),
        // contentPadding: lines != null
        //     ? const EdgeInsets.symmetric(
        //         vertical: 15,
        //         horizontal: 15,
        //       )
        //     : null,
      ),
      validator: validadores.isEmpty ? null : (value) => combo(validadores),
      onChanged: onChanged!,
    );
  }
}

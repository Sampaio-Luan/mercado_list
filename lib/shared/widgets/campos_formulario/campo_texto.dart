import 'package:flutter/material.dart';

import '../../../core/mixins/validacoes_mixin.dart';

class CampoDeTexto extends StatelessWidget with ValidacoesMixin {
  final String rotulo;
  final String valor;
  final List<String? Function()> validadores;
  final int? linhas;
  final bool habilitado;

  final void Function(String v)? onChanged;

  CampoDeTexto({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.validadores,
    this.linhas,
    this.habilitado = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valor,
      enabled: habilitado,
      maxLines: linhas ?? 1,
      maxLength: linhas != null ? 255 : null,
      decoration: InputDecoration(
        label: Text(rotulo),
      ),
      validator: validadores.isEmpty ? null : (value) => combo(validadores),
      onChanged: habilitado ? onChanged : null,
    );
  }
}

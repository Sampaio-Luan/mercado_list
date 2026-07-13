import 'package:flutter/material.dart';

import '../constants/enums/tipo_dialogo.dart';
import '../services/dialogo_service.dart';



extension DialogoExtension on BuildContext {
  Future<void> sucesso({required String mensagem, String titulo = 'Sucesso'}) {
    return DialogoService.mostrar(
      context: this,
      tipo: TipoDialogo.sucesso,
      titulo: titulo,
      mensagem: mensagem,
    );
  }

  Future<void> erro({required String mensagem, String titulo = 'Erro'}) {
    return DialogoService.mostrar(
      context: this,
      tipo: TipoDialogo.erro,
      titulo: titulo,
      mensagem: mensagem,
    );
  }

  Future<void> informacao({
    required String mensagem,
    String titulo = 'Informação',
  }) {
    return DialogoService.mostrar(
      context: this,
      tipo: TipoDialogo.informacao,
      titulo: titulo,
      mensagem: mensagem,
    );
  }

  Future<ResultadoDialogo?> confirmar({
    required String titulo,
    required String mensagem,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
  }) {
    return DialogoService.mostrar(
      context: this,
      tipo: TipoDialogo.aviso,
      titulo: titulo,
      mensagem: mensagem,
      textoConfirmar: textoConfirmar,
      textoCancelar: textoCancelar,
      exibirCancelar: true,
    );
  }
}

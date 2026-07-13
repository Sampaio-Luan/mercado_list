import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';



class PreferenciasService {
  static const String chave = 'preferencias_usuario';

  final SharedPreferences prefs;

  PreferenciasService(this.prefs);

static const String msg = '🛠️🥇PreferenciasService: ';

  Future<void> salvar(
    PreferenciasUsuario preferencias,
  ) async {
    await prefs.setString(
      chave,
      jsonEncode(preferencias.toJson()),
    );
    log(name:msg, 'salvar(): Preferências salvas com sucesso. ${preferencias.toJson()}', time: DateTime.now());
  }

  PreferenciasUsuario carregar() {
    final jsonString = prefs.getString(chave);

    if (jsonString == null) {
      log(name: msg,'carregar():  Preferencias não encontradas, retornando padrão.', time: DateTime.now());
      return PreferenciasUsuario.padrao();
    }
    log(name: msg,'carregar():  Preferencias carregadas com sucesso.', time: DateTime.now());
    return PreferenciasUsuario.fromJson(
      jsonDecode(jsonString),
    );
  }
}

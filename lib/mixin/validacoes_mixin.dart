mixin ValidacoesMixin {
  String? isEmpty(String? value, [String? message]) {
    if (value == null || value.isEmpty) return message ?? 'Obrigatório';
    return null;
  }

  String? justOneWord(String? value, [String? message]) {
    if (value!.contains(' ')) {
      return message ?? 'Apenas uma palavra!';
    }
    return null;
  }

  String? minimumCharacters(String? value, int min, [String? message]) {
    if (value!.length < min) {
      return message ?? "Você deve usar pelo menos $min caracteres";
    }
    return null;
  }

  String? numeroDeveSerMaior(String? value, int min, [String? message]) {
    if (value == null || value.isEmpty) return "Minimo $min";
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (int.parse(value) < min) {
      return message ?? "Minimo $min";
    }
    return null;
  }

  String? numeroDeveSerMenor(String? value, int max, [String? message]) {
    if (value == null || value.isEmpty) return "Máximo $max";
    value =  value.replaceAll(RegExp(r'[^0-9]'), '');
    if (int.parse(value) > max) {
      value = value.replaceAll(RegExp(r'[^0-9]'), '');
      return message ?? "Máximo $max";
    }
    return null;
  }

  String? combo(List<String? Function()> validators) {
    for (final func in validators) {
      final validation = func();
      if (validation != null) return validation;
    }
    return null;
  }
}

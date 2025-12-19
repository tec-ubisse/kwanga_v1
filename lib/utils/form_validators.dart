class FormValidators {

  static String? requiredText(String? value, {String message = 'Campo obrigatório'}) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? requiredSelection<T>(T? value, {String message = 'Seleção obrigatória'}) {
    if (value == null) return message;
    return null;
  }
}

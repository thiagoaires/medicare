import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  static String format(String value) {
    if (value.isEmpty) return '';

    // 1. Obter apenas os números
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    // 2. Limitar a 11 dígitos
    final truncated = digitsOnly.length > 11
        ? digitsOnly.substring(0, 11)
        : digitsOnly;

    // 3. Reconstruir a string formatada
    final buffer = StringBuffer();
    for (int i = 0; i < truncated.length; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(truncated[i]);
    }

    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Reutilizar o método estático para formatação
    // Nota: O método format reconstrói toda a string.
    // Para edição, isso posiciona o cursor no fim, o que é o comportamento simplificado aceitável aqui.
    // Se digitacao for incremental, precisamos apenas garantir que o novo texto seja formatado.

    final newText = newValue.text;
    // Se estiver apagando, permitir comportamento padrão pode ser melhor ou usar lógica especifica.
    // Mas para máscara simples, reformatar sempre o valor limpo funciona.

    final formattedText = format(newText);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

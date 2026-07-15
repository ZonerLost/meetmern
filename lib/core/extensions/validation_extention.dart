extension EmailValidator on String {
  bool get isValidEmail {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(this);
  }
}

class PasswordRules {
  PasswordRules._();

  static const int minLength = 8;
  static const int maxLength = 15;
  static const String allowedSymbols = '@#\$%^&*';

  static final Set<String> _allowedSymbolSet = allowedSymbols.split('').toSet();
  static final RegExp _letterOrDigit = RegExp(r'^[A-Za-z0-9]$');
  static final RegExp _whitespace = RegExp(r'\s');

  static String get helperText =>
      'Password must be $minLength-$maxLength characters long. Allowed characters: letters, numbers, and symbols.';

  static String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Password must be at most $maxLength characters';
    }
    if (_whitespace.hasMatch(value)) {
      return 'Password cannot contain spaces';
    }

    for (final char in value.split('')) {
      if (_letterOrDigit.hasMatch(char) || _allowedSymbolSet.contains(char)) {
        continue;
      }
      return 'Use only letters, numbers, and supported symbols i.e. $allowedSymbols';
    }

    return null;
  }
}

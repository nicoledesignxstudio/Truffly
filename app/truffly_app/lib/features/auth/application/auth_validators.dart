import 'package:truffly_app/l10n/app_localizations.dart';

final class AuthValidators {
  AuthValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static String? validateEmail(
    String? value,
    AppLocalizations l10n,
  ) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return l10n.emailRequired;
    if (!_emailRegex.hasMatch(email)) return l10n.invalidEmail;
    return null;
  }

  static String? validatePassword(
    String? value,
    AppLocalizations l10n,
  ) {
    final password = (value ?? '').trim();
    if (password.isEmpty) return l10n.passwordRequired;
    if (password.length < 8) return l10n.passwordTooShort;

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    if (!hasLetter || !hasDigit) {
      return l10n.passwordLettersNumbers;
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? confirmPassword,
    String password,
    AppLocalizations l10n,
  ) {
    final confirm = (confirmPassword ?? '').trim();
    if (confirm.isEmpty) return l10n.confirmPasswordRequired;
    if (confirm != password) return l10n.passwordsDoNotMatch;
    return null;
  }
}


import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final Map<String, String> errorCodeToMessageKey = {
  'user-not-found': 'apiErrorUserNotFound',
  'wrong-password': 'apiErrorWrongPassword',
  'user-disabled': 'apiErrorUserDisabled',
  'invalid-email': 'apiErrorInvalidEmail',
  'channel-error': 'apiErrorChannelError',
  'weak-password': 'apiErrorWeakPassword',
  'invalid-credential': 'apiErrorInvalidCredential',
  // Add other mappings as needed
};

extension AppLocalizationsExtension on AppLocalizations {
  String getString(String key) {
    // This is a simplified example. You might need to implement a more complex logic
    // depending on how your localizations are structured.
    switch (key) {
      case 'apiErrorUserNotFound':
        return this.apiErrorUserNotFound;
      case 'apiErrorWrongPassword':
        return this.apiErrorWrongPassword;
      case 'apiErrorUserDisabled':
        return this.apiErrorUserDisabled;
      case 'apiErrorInvalidEmail':
        return this.apiErrorInvalidEmail;
      case 'apiErrorChannelError':
        return this.apiErrorChannelError;
      case 'apiErrorWeakPassword':
        return this.apiErrorWeakPassword;
      case 'apiErrorInvalidCredential':
        return this.apiErrorInvalidCredential;
    // Add more cases as needed
      default:
        return key; // Fallback to returning the key itself if not found
    }
  }
}
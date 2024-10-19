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
  String getString(final String key) {
    // This is a simplified example. You might need to implement a more complex logic
    // depending on how your localizations are structured.
    switch (key) {
      case 'apiErrorUserNotFound':
        return apiErrorUserNotFound;
      case 'apiErrorWrongPassword':
        return apiErrorWrongPassword;
      case 'apiErrorUserDisabled':
        return apiErrorUserDisabled;
      case 'apiErrorInvalidEmail':
        return apiErrorInvalidEmail;
      case 'apiErrorChannelError':
        return apiErrorChannelError;
      case 'apiErrorWeakPassword':
        return apiErrorWeakPassword;
      case 'apiErrorInvalidCredential':
        return apiErrorInvalidCredential;
    // Add more cases as needed
      default:
        return key; // Fallback to returning the key itself if not found
    }
  }
}
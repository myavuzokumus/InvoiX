import 'package:flutter/material.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/global_provider.dart';
import 'package:invoix/utils/status/network_check.dart';

enum Status {
  noInternetConnection,
  noUsageRights,
  noLogin,
  somethingWentWrong,
}

extension StatusExtension on Status {
  String get name {
    switch (this) {
      case Status.noInternetConnection:
        return LocalizationManager.instance.appLocalization.status_noInternetConnection;
      case Status.noUsageRights:
        return LocalizationManager.instance.appLocalization.status_noUsageRights;
      case Status.noLogin:
        return LocalizationManager.instance.appLocalization.status_noLogin;
      case Status.somethingWentWrong:
        return LocalizationManager.instance.appLocalization.status_somethingWentWrong;
      default:
        return "";
    }
  }

  IconData get icon {
    switch (this) {
      case Status.noInternetConnection:
        return Icons.phonelink_erase_rounded;
      case Status.noUsageRights:
        return Icons.data_usage;
      case Status.noLogin:
        return Icons.account_circle;
      case Status.somethingWentWrong:
        return Icons.error;
      default:
        return Icons.account_tree_outlined;
    }
  }

}

Future<Status> currentStatusChecker([final String? usageCheckType]) async {

  final firebaseService = GlobalProviderContainer.get().read(firebaseServiceProvider);

  if (!await isInternetConnected()) {
    return Status.noInternetConnection;
  }
  else if (firebaseService.getUser() == null) {
    return Status.noLogin;
  }
  else if (usageCheckType != null && !(await firebaseService.checkUsageRights(usageCheckType))["success"]) {
    return Status.noUsageRights;
  }
  else {
    return Status.somethingWentWrong;
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/global_provider.dart';
import 'package:invoix/utils/status/network_check.dart';

enum Status {
  noInternetConnection,
  noUsageRights,
  somethingWentWrong,
}

extension StatusExtension on Status {
  String get name {
    switch (this) {
      case Status.noInternetConnection:
        return "No Internet Connection!";
      case Status.noUsageRights:
        return "You have no more rights to use AI features.";
      case Status.somethingWentWrong:
        return "Something went wrong.";
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
      case Status.somethingWentWrong:
        return Icons.error;
      default:
        return Icons.account_tree_outlined;
    }
  }


}

Future<Status> currentStatusChecker(final String usageCheckType) async {

  final firebaseService = GlobalProviderContainer.get().read(firebaseServiceProvider);

  if (!await isInternetConnected()) {
    return Status.noInternetConnection;
  }
  else if (!(await firebaseService.checkUsageRights(usageCheckType))["success"]) {
    return Status.noUsageRights;
  }
  else {
    return Status.somethingWentWrong;
  }

}

import 'package:flutter/material.dart';
import 'package:invoix/utils/status/current_status_checker.dart';
import 'package:invoix/widgets/status/status_widget.dart';

class ShowCurrentStatus extends StatelessWidget {
  const ShowCurrentStatus({super.key, required this.status, this.customHeight});

  final Status status;
  final double? customHeight;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      height: customHeight ?? double.maxFinite,
      child: StatusWidget(status: status),
    );
  }

}

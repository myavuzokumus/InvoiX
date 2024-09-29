import 'package:flutter/material.dart';
import 'package:invoix/utils/status/current_status_checker.dart';

class StatusWidget extends StatelessWidget {
  const StatusWidget({super.key, required this.status});

  final Status status;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment:
      MainAxisAlignment.spaceEvenly,
      children: [
        Icon(status.icon,
            size: 92, color: Colors.red),
        Text(status.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

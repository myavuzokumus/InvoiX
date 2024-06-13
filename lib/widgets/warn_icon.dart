import 'package:flutter/material.dart';

class WarnIcon extends Tooltip {
  const WarnIcon({super.key, required final String message})
      : super(
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 5),
      message: message,
      child: const Icon(
        Icons.info_outline,
        size: 24,
      )
  );
}

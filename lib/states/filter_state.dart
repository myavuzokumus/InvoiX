import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filterPanelVisibleProvider = Provider<ValueNotifier<bool>>((final ref) {
  return ValueNotifier<bool>(false);
});
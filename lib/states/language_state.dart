// Create a provider for the current locale
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((final ref) => const Locale('en', ''));
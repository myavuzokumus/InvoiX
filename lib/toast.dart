import 'package:flutter/material.dart';

void showSnackBar(final BuildContext context, {required final String text, final Color color = Colors.deepOrangeAccent}) {
  final snackBar = SnackBar(
    content: Text(text),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(50),
    elevation: 30,
    duration: const Duration(milliseconds: 10000),
    showCloseIcon: true,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

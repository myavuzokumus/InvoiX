import 'package:flutter/material.dart';

void Toast(final BuildContext context,
    {required final String text, final Color color = Colors.deepOrangeAccent}) {

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final snackBar = SnackBar(
    content: Text(text, style: const TextStyle(color: Colors.white)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(50),
    elevation: 30,
    duration: const Duration(milliseconds: 10000),
    showCloseIcon: true,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
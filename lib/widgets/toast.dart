import 'package:flutter/material.dart';

class Toast extends SnackBar {
  Toast({super.key, required final String text, final Color color = Colors.deepOrangeAccent})
      : super(
    content: Text(text, style: const TextStyle(color: Colors.white)),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(50),
    elevation: 30,
    duration: const Duration(milliseconds: 10000),
    showCloseIcon: true,
  );
}

/*
class Toast extends StatelessWidget implements SnackBar {
  final String text;
  final Color color;
  const Toast({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(50),
      elevation: 30,
      duration: const Duration(milliseconds: 10000),
      showCloseIcon: true,
    );
  }
}

void toast(final BuildContext context,
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
*/

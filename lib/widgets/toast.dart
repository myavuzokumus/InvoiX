import 'package:flutter/material.dart';

void Toast(final BuildContext context,
    {required final String text, final Color color = Colors.deepOrangeAccent}) {

  const duration = Duration(milliseconds: 10000);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final snackBar = SnackBar(
    content: ToastContent(text: text, duration: duration),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(50),
    elevation: 30,
    duration: duration,
    padding: const EdgeInsets.all(0)
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class ToastContent extends StatefulWidget {
  final String text;
  final Duration duration;

  const ToastContent({super.key, required this.text, required this.duration});

  @override
  State<ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<ToastContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(widget.text, style: const TextStyle(color: Colors.white)),
        ),
        AnimatedBuilder(animation: _controller,
        builder: (final BuildContext context, final Widget? child) => LinearProgressIndicator(value: 1.0 - _controller.value)),
      ],
    );
  }
}

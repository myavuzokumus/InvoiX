import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

final Map<String, Duration> toastTimers = {};

void showToast({
  required final String text,
  final Color color = Colors.deepOrangeAccent,
  final Duration duration = const Duration(seconds: 10),
}) {

  scaffoldMessengerKey.currentState?.clearSnackBars();

  final snackBar = SnackBar(
    content: ToastContent(text: text, duration: duration),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(50),
    elevation: 30,
    duration: duration,
    padding: EdgeInsets.zero,
  );

  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);

  Future.delayed(duration, () {
    toastTimers.remove(text);
  });
}

class ToastContent extends StatefulWidget {
  final String text;
  final Duration duration;

  const ToastContent({super.key,
    required this.text,
    required this.duration,
  });

  @override
  State<ToastContent> createState() => _ToastContentState();
}

class _ToastContentState extends State<ToastContent> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Duration? newDuration;

  @override
  void initState() {
    super.initState();

    if (toastTimers.containsKey(widget.text)) {
      newDuration = toastTimers[widget.text]!.inSeconds > 1 ? toastTimers[widget.text] : const Duration(seconds: 10);
    }
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward(from: newDuration != null ? 1 - newDuration!.inSeconds/10 : 0);
  }

  @override
  void dispose() {
    final time = ((1 - _controller.value) * 10).toInt();
    if (Duration(seconds: time).inSeconds > 1) {
      toastTimers[widget.text] = Duration(seconds: time);
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant final ToastContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.dispose();
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      )..forward(from: newDuration != null ? 1 - newDuration!.inSeconds/10 : 0);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(widget.text, style: const TextStyle(color: Colors.white)),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (final context, final child) {
            return LinearProgressIndicator(
              value: widget.duration.inSeconds/10 - _controller.value,
            );
          },
        ),
      ],
    );
  }
}

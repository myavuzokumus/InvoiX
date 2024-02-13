import 'package:flutter/material.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        Expanded(child: Center(child: Image.asset("assets/loading/InvoiceReadLoading.gif"))),
      ],
    );
  }
}

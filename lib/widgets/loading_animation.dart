import 'package:flutter/material.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key, this.customHeight});

  final double? customHeight;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
        height: customHeight ?? double.maxFinite,
        child: Column(
          children: [
            const LinearProgressIndicator(),
            Expanded(child: Center(child: Image.asset("assets/loading/InvoiceReadLoading.gif"))),
      ],
    ));
  }
}

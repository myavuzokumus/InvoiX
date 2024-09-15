import 'package:flutter/material.dart';
import 'package:invoix/pages/SubscriptionPage/subscription_page.dart';
import 'package:invoix/widgets/loading_animation.dart';

class SubStatus extends StatelessWidget {
  const SubStatus({
    super.key,
    required this.errorState,
    required this.subsControl,
  });

  final ErrorState errorState;
  final bool subsControl;

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SubscriptionPage()),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.yellow[900],
        child: const Text(
          "Check subscription",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
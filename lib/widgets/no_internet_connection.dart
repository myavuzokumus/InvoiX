import 'package:flutter/material.dart';

class NoInternetConnection extends StatelessWidget {
  const NoInternetConnection({super.key});

  @override
  Widget build(final BuildContext context) {
    return const Column(
      mainAxisAlignment:
      MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.phonelink_erase_rounded,
            size: 92, color: Colors.red),
        Text('No Internet Connection',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

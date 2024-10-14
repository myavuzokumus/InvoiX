import 'package:flutter/material.dart';

class InvoixAICard extends StatelessWidget {
  const InvoixAICard({super.key, required this.children, this.onPressed});

  final List<Widget> children;
  final VoidCallback? onPressed;

  @override
  Widget build(final BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.20, 0.5, 0.80],
          colors: [Color(0xFFDA0000),Color(
              0xFFFF8F00),Color(0x66880202)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          splashColor: Colors.blue,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                  child: ListView(
                    //physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: children,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: const Text("✨", style: TextStyle(fontSize: 54)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
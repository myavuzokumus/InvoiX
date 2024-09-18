import 'package:flutter/material.dart';
import 'package:invoix/widgets/glowing_container.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final String buttonText;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onPressed;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.features,
    required this.buttonText,
    required this.icon,
    this.glowColor = Colors.blue,
    required this.onPressed,
  });

  @override
  Widget build(final BuildContext context) {
    return GlowingContainer(
      glowColor: glowColor,
      child: Card(
        color: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 32, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(price, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                Column(
                  children: [
                    ...features.map((final feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(child: Text(feature, style: const TextStyle(color: Colors.white, fontSize: 16))),
                        ],
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: glowColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(buttonText, style: const TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
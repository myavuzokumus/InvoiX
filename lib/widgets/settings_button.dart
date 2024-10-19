import 'package:flutter/material.dart';

class SettingsButton extends ElevatedButton {
  SettingsButton({
    super.key,
    required final IconData icon,
    required final String label,
    required VoidCallback super.onPressed,
  }) : super(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.grey[800],
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 18)),
      ],
    ),
  );
}

// Widget _buildElevatedButton({
//   required final IconData icon,
//   required final String label,
//   required final VoidCallback onPressed,
// }) {
//   return ElevatedButton(
//     style: ElevatedButton.styleFrom(
//       foregroundColor: Colors.white,
//       backgroundColor: Colors.grey[800],
//       minimumSize: const Size(double.infinity, 50),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(24),
//       ),
//     ),
//     onPressed: onPressed,
//     child: Row(
//       children: [
//         Icon(icon),
//         const SizedBox(width: 8),
//         Text(label, style: const TextStyle(fontSize: 18)),
//       ],
//     ),
//   );
// }

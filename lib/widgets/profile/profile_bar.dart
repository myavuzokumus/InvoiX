import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/widgets/glowing_container.dart';
import 'package:invoix/widgets/profile/profile_dropdown.dart';

class ProfileBar extends ConsumerWidget {
  const ProfileBar({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final firebaseService = ref.watch(firebaseServiceProvider);
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (final User? user) {
        return StreamBuilder<DocumentSnapshot?>(
          stream: user != null ? firebaseService.getUserSubscriptionStream() : Stream.value(null),
          builder: (final context, final snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            String? subscriptionId;
            final Color glowColor;

            if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
              final data = snapshot.data!.data()! as Map<String, dynamic>;
              subscriptionId = data['subscriptionId'] as String?;
            }

            switch (subscriptionId) {
              case 'individual_subscription':
                glowColor = Colors.blue;
                break;
              case 'advanced_subscription':
                glowColor = Colors.purple;
                break;
              case 'corporate_subscription':
                glowColor = Colors.orange;
                break;
              case 'new_user_offer':
                glowColor = Colors.green;
                break;
              default:
                glowColor = Colors.grey;
                break;
            }

            return GestureDetector(
              onTap: () => _showProfileDropdown(context, user, glowColor),
              child: GlowingContainer(
                glowColor: glowColor,
                child: CircleAvatar(
                  backgroundImage: user == null
                      ? const AssetImage("assets/loading/InvoiceReadLoading.gif")
                      : NetworkImage(user.photoURL!) as ImageProvider,
                ),
              ),
            );
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (final error, final stack) => Text('Error: $error'),
    );
  }
  void _showProfileDropdown(final BuildContext context, final User? user, final Color glowColor) {
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final Offset buttonPosition = button.localToGlobal(Offset.zero);
    final Size buttonSize = button.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (final BuildContext context) {
        return Stack(
          children: [
            Positioned(
              right: MediaQuery.of(context).size.width - buttonPosition.dx - buttonSize.width,
              top: buttonPosition.dy + buttonSize.height,
              child: Material(
                color: Colors.transparent,
                child: ProfileDropdown(
                  glowColor: glowColor,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

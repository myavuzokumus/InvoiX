import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/models/firebase_state.dart';
import 'package:invoix/pages/SubscriptionPage/new_user_offer.dart';
import 'package:invoix/pages/SubscriptionPage/subscription_page.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/widgets/glowing_container.dart';
import 'package:invoix/widgets/toast.dart';

class ProfileDropdown extends ConsumerWidget {
  final Color glowColor;

  const ProfileDropdown({
    super.key,
    required this.glowColor,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final firebaseService = ref.watch(firebaseServiceProvider);
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (final user) {
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (user != null) ...[
                        Text(user.email ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 16),
                        GlowingContainer(
                          glowColor: glowColor,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(user.photoURL ?? ''),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(user.displayName ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ] else ...[
                        _buildGoogleLoginButton(context, firebaseService),
                        Text(localizations.loginToUseAI,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ],
                  ),
                ),
                Divider(color: Colors.grey[700]),
                if (user != null) ...[
                  _buildUserSubscriptionInfo(firebaseService, localizations),
                ] else ...[
                  const NewUserOffer(),
                ],
                Divider(color: Colors.grey[700]),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      _buildElevatedButton(
                        icon: Icons.shopping_cart,
                        label: localizations.plans,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final context) =>
                                    const SubscriptionPage()),
                          );
                        },
                      ),
                      if (user != null) const SizedBox(height: 8),
                      if (user != null)
                        _buildElevatedButton(
                          icon: Icons.exit_to_app,
                          label: localizations.logOut,
                          onPressed: () async {
                            await firebaseService.signOut();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (final error, final stack) => Text('Error: $error'),
    );
  }

  Widget _buildGoogleLoginButton(
      final BuildContext context, final FirebaseService firebaseService) {
    return TextButton(
      child: Image.asset(
        'assets/icons/google_login.png',
        scale: 2 * MediaQuery.of(context).devicePixelRatio,
      ),
      onPressed: () => _handleGoogleLogin(context, firebaseService),
    );
  }

  Future<void> _handleGoogleLogin(
      final BuildContext context, final FirebaseService firebaseService) async {
    try {
      final user = await firebaseService.signInWithGoogle();
      if (user != null) {
        Toast(context, text: "Başarıyla giriş yapıldı!", color: Colors.green);
      } else {
        Toast(context, text: "Giriş yapılırken bir hata oluştu!");
      }
    } catch (e) {
      Toast(context, text: "Giriş yapılırken bir hata oluştu: $e");
    }
  }

  Widget _buildUserSubscriptionInfo(final FirebaseService firebaseService,
      final AppLocalizations localizations) {
    return StreamBuilder<DocumentSnapshot?>(
      stream: firebaseService.getUserSubscriptionStream(),
      builder: (final context, final snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error loading data: ${snapshot.error}',
              style: const TextStyle(color: Colors.red));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('No subscription data available',
              style: TextStyle(color: Colors.white));
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return Column(
          children: [
            _buildInfoTile("Plan", '${userData['subscriptionId'] ?? 'None'}'),
            _buildInfoTile(localizations.remainingInvoiceReads,
                '${userData['aiInvoiceReads'] ?? 0}'),
            _buildInfoTile(localizations.remainingInvoiceAnalyses,
                '${userData['aiInvoiceAnalyses'] ?? 0}'),
            _buildInfoTile(localizations.subscriptionExpiryDate,
                _formatDate(userData['subscriptionExpiryDate'])),
          ],
        );
      },
    );
  }

  Widget _buildInfoTile(final String title, final String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  String _formatDate(final dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      return date.toDate().toString().split(' ')[0]; // Returns YYYY-MM-DD
    }
    return date.toString();
  }

  Widget _buildElevatedButton({
    required final IconData icon,
    required final String label,
    required final VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.grey[800],
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

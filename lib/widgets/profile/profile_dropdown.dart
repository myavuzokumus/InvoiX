import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/pages/SubscriptionPage/new_user_offer.dart';
import 'package:invoix/pages/SubscriptionPage/subscription_page.dart';
import 'package:invoix/pages/settings_page.dart';
import 'package:invoix/services/firebase_service.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/utils/status/current_status_checker.dart';
import 'package:invoix/widgets/glowing_container.dart';
import 'package:invoix/widgets/settings_button.dart';
import 'package:invoix/widgets/status/loading_animation.dart';
import 'package:invoix/widgets/status/show_current_status.dart';
import 'package:invoix/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileDropdown extends ConsumerWidget {
  final Color glowColor;

  const ProfileDropdown({
    super.key,
    required this.glowColor,
  });

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {

    final firebaseService = ref.watch(firebaseServiceProvider);
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (final user) {
        return Container(
          width: 296,
          height: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.height * 0.7 : null,
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
                            child: ClipOval(
                              child: FadeInImage.assetNetwork(
                                placeholder: '', // Path to your loading icon
                                image: user.photoURL ?? '',
                                fit: BoxFit.cover,
                                placeholderErrorBuilder: (final context, final error, final stackTrace) {
                                  return const Center(child: CircularProgressIndicator());
                                },
                                imageErrorBuilder: (final context, final error, final stackTrace) {
                                  return const Icon(Icons.error); // Display an error icon if the image fails to load
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(user.providerData[0].displayName ?? '',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                      ] else ...[
                        _buildGoogleLoginButton(context, firebaseService),
                        Text(context.l10n.auth_loginToUseAI,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ],
                  ),
                ),
                Divider(color: Colors.grey[700]),
                if (user != null) ...[
                  _buildUserSubscriptionInfo(firebaseService),
                ] else ...[
                  // Policy and terms
                  _buildPolicyAndTerms(context, firebaseService),
                  // New user offer
                  FutureBuilder<SharedPreferences>(future: SharedPreferences.getInstance(), builder: (final context, final snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final bool isFirstLogin = snapshot.data!.getBool('isFirstLogin') ?? true;
                      if (isFirstLogin) {
                        return const NewUserOffer();
                      }
                    }
                    return const SizedBox();
                  }),
                ],
                Divider(color: Colors.grey[700]),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      SettingsButton(
                        icon: Icons.shopping_cart,
                        label: context.l10n.subsplan_plans,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final context) =>
                                    const SubscriptionPage()),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      SettingsButton(
                          icon: Icons.settings,
                          label: context.l10n.settings_settings,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (final context) =>
                                      const SettingsPage()),
                            );
                          }),
                      if (user != null) const SizedBox(height: 8),
                      if (user != null)
                        SettingsButton(
                          icon: Icons.exit_to_app,
                          label: context.l10n.auth_logOut,
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
      loading: () => const LoadingAnimation(),
      error: (final error, final stack) => LayoutBuilder(builder:
          (final BuildContext context, final BoxConstraints constraints) {
        return FutureBuilder<Status>(
          future: currentStatusChecker(""),
          builder: (final context, final statusSnapshot) {
            if (statusSnapshot.connectionState == ConnectionState.done) {
              return ShowCurrentStatus(
                  status: statusSnapshot.data!,
                  customHeight: constraints.maxHeight - 72);
            }
            return const LoadingAnimation();
          },
        );
      }),
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
      await firebaseService.signInWithGoogle();
    } catch (e) {
      showToast(
          text: context.l10n.auth_loginError(await currentStatusChecker().then((final value) => value.name)));
    }
  }

  Widget _buildPolicyAndTerms(final BuildContext context, final FirebaseService firebaseService) {
    return Column(
      children: [
        Text(context.l10n.settings_byLoginYouAgree,
            style: TextStyle(color: Colors.grey[400])),
        TextButton(
          onPressed: () async {
            final Uri url = Uri.parse(firebaseService.remoteConfig.getString('privacy_url'));
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              showToast(text: context.l10n.status_somethingWentWrong);
            }
          },
          child: Text(context.l10n.settings_privacyPolicy,
              style: const TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () async {
            final Uri url = Uri.parse(firebaseService.remoteConfig.getString('terms_url'));
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              showToast(text: context.l10n.status_somethingWentWrong);
            }
          },
          child: Text(context.l10n.settings_termsOfService,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildUserSubscriptionInfo(final FirebaseService firebaseService) {
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
          return Text(context.l10n.profile_noData,
              style: const TextStyle(color: Colors.white));
        }
        final userData = snapshot.data!.data()! as Map<String, dynamic>;
        return Column(
          children: [
            _buildInfoTile("Plan", '${userData['subscriptionId'] ?? 'None'}'),
            _buildInfoTile(context.l10n.profile_remainingInvoiceReads,
                '${userData['aiInvoiceReads'] ?? 0}'),
            _buildInfoTile(context.l10n.profile_remainingInvoiceAnalyses,
                '${userData['aiInvoiceAnalyses'] ?? 0}'),
            _buildInfoTile(context.l10n.profile_subscriptionExpiryDate,
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


}

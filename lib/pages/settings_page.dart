import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoix/l10n/localization_extension.dart';
import 'package:invoix/pages/welcome_page.dart';
import 'package:invoix/states/firebase_state.dart';
import 'package:invoix/states/language_state.dart';
import 'package:invoix/widgets/settings_button.dart';
import 'package:invoix/widgets/toast.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final firebaseService = ref.watch(firebaseServiceProvider);
    final user = firebaseService.getUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings_settings),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: user != null ? 4 : 3,
        itemBuilder: (final context, final index) {
          if (index == 0) {
            return SettingsButton(
              icon: Icons.pageview,
              label: context.l10n.settings_welcomePage,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (final context) => WelcomePage(
                      onDone: () {
                        Navigator.popUntil(
                            context, (final route) => route.isFirst);
                      },
                    ),
                  ),
                );
              },
            );
          } else if (index == 1) {
            return SettingsButton(
              icon: Icons.language,
              label: context.l10n.settings_changeLanguage,
              onPressed: () => _showLanguageDialog(context, ref),
            );
          } else if (index == 2 && user != null) {
            return SettingsButton(
              icon: Icons.delete_forever,
              label: context.l10n.settings_deleteAccount,
              onPressed: () => _showDeleteAccountDialog(context, ref),
            );
          } else {
            return _buildPolicyAndTerms(context);
          }
        },
        separatorBuilder: (final context, final index) =>
            const SizedBox(height: 16),
      ),
    );
  }

  Widget _buildPolicyAndTerms(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: Text(context.l10n.settings_privacyPolicy,
              style: const TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {},
          child: Text(context.l10n.settings_termsOfService,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showLanguageDialog(final BuildContext context, final WidgetRef ref) {
    final supportedLocales = LocalizationManager.instance.getSupportedLocales();
    final currentLocale = ref.watch(localeProvider);

    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.settings_selectLanguage),
          content: ListView.separated(
            shrinkWrap: true,
            itemCount: supportedLocales.length,
            itemBuilder: (final context, final index) {
              final locale = supportedLocales[index];
              final isSelected = locale.languageCode == currentLocale.languageCode;
              return ListTile(
                title: Text(LocalizationManager.instance.getLanguageName(locale)),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  LocalizationManager.instance.changeLocale(locale, ref);
                  Navigator.pop(context);
                },
              );
            },
            separatorBuilder: (final context, final index) =>
            const SizedBox(height: 8),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(
      final BuildContext context, final WidgetRef ref) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.settings_deleteAccountConfirmTitle,
              style: const TextStyle(color: Colors.red)),
          content: Text(context.l10n.settings_deleteAccountConfirmMessage,
              style: const TextStyle(decoration: TextDecoration.underline)),
          actions: [
            TextButton(
              child: Text(context.l10n.settings_cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(context.l10n.settings_deleteAccountConfirmYes),
              onPressed: () async {
                try {
                  final firebaseService = ref.read(firebaseServiceProvider);
                  await firebaseService.deleteAccount();
                  Toast(context,
                      text: context.l10n.settings_deleteAccountSuccess);
                  Navigator.of(context)
                      .popUntil((final route) => route.isFirst);
                } catch (e) {
                  Toast(context,
                      text: context.l10n.settings_deleteAccountError);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

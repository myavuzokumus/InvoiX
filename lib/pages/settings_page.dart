import 'package:flutter/material.dart';
import 'package:invoix/pages/welcome_page.dart';
import 'package:invoix/widgets/settings_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsButton(
            icon: Icons.pageview,
            label: 'Hoş Geldin Sayfasını Göster',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (final context) => WelcomePage(
                    onDone: () {
                      Navigator.popUntil(
                          context, (final route) => route.isFirst);
                      //Navigator.pop(context);
                      //Navigator.pop(context);
                      //Navigator.pop(context);
                    },
                  ),
                ),
              );
            },
          ),
          // Diğer ayarlar buraya eklenebilir...
        ],
      ),
    );
  }
}

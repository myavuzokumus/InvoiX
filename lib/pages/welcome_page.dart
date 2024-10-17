import 'package:flutter/material.dart';
import 'package:invoix/l10n/localization_extension.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onDone;

  const WelcomePage({super.key, required this.onDone});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late final List<Map<String, String>> welcomeData;

  @override
  initState() {

    welcomeData = [
      {
        "title": context.l10n.welcomePage_title_1,
        "description": context.l10n.welcomePage_description_1,
        "image": "assets/icons/welcome/easy_use.png",
      },
      {
        "title": context.l10n.welcomePage_title_2,
        "description": context.l10n.welcomePage_description_2,
        "image": "assets/icons/welcome/fast_process.png",
      },
      {
        "title": context.l10n.welcomePage_title_3,
        "description": context.l10n.welcomePage_description_3,
        "image": "assets/icons/welcome/secure_infrastructure.png",
      },
    ];

    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (final int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: welcomeData.length,
            itemBuilder: (final context, final index) {
              return buildPageContent(welcomeData[index]);
            },
          ),
          Positioned(
            bottom: 50.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                welcomeData.length,
                (final index) => buildDot(index),
              ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            right: 20.0,
            child: _currentPage == welcomeData.length - 1
                ? ElevatedButton(
                    child: Text(context.l10n.button_start),
                    onPressed: () {
                      widget.onDone();
                    },
                  )
                : TextButton(
                    child: Text(context.l10n.button_skip),
                    onPressed: () {
                      _pageController.animateToPage(
                        welcomeData.length - 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPageContent(final Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            data["image"]!,
            height: 300.0,
          ),
          const SizedBox(height: 50.0),
          Text(
            data["title"]!,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20.0),
          Text(
            data["description"]!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  Widget buildDot(final int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      height: 10.0,
      width: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index ? Colors.blue : Colors.grey,
      ),
    );
  }
}

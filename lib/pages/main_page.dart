import 'package:flutter/material.dart';
import 'package:invoix/pages/CompaniesPage/company_main.dart';
import 'package:invoix/pages/SummaryPage/summary_main.dart';
import 'package:invoix/utils/navigation_utils.dart';
import 'package:invoix/utils/read_mode.dart';
import 'package:invoix/widgets/status/loading_animation.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const CompanyPage(),
    const SummaryMain(),
  ];

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  final PageController _pageController = PageController();
  late ReadMode readMode = ReadMode.ai; // Initialize readMode here

  void onTabTapped(final int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: onTabTapped,
            controller: _pageController,
            children: _children,
          ),
          ValueListenableBuilder(
            valueListenable: _isLoadingNotifier,
            builder: (final BuildContext context, final value, final Widget? child) {
              return value == true
                  ? Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.black38,
                  child: const Center(child: LoadingAnimation()))
                  : const SizedBox();
            },
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Companies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Summary',
          ),
        ],
      ),
      floatingActionButton: Badge(
        label: const Icon(Icons.add, color: Colors.white, size: 20),
        largeSize: 28,
        backgroundColor: Colors.red,
        offset: const Offset(10, -10),
        child: FloatingActionButton(
            onPressed: () => nextPage(context, _isLoadingNotifier, readMode),
            child: const Icon(Icons.receipt_long, size: 46)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//I made this page so it would be easier to manage if I added anything in the future.
//I will also add a navigation bar to navigate between these pages.

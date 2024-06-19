import 'package:flutter/material.dart';
import 'package:invoix/pages/CompaniesPage/company_main.dart';
import 'package:invoix/pages/SummaryPage/summary_main.dart';

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

  void onTabTapped(final int index) {
    setState(() {
      _currentIndex = index;
    });
    // onTap event'inde, PageController'ın animateToPage metodunu çağırın
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
  }

  final PageController _pageController = PageController();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: onTabTapped,
        controller: _pageController,
        children: _children,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}

//I made this page so it would be easier to manage if I added anything in the future.
//I will also add a navigation bar to navigate between these pages.

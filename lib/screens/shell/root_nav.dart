import 'package:flutter/material.dart';
import '../home/home_today_screen.dart';
import '../learn/learn_basics_screen.dart';
import '../practice/question_screen.dart';
import '../progress/progress_screen.dart';
import '../account/account_screen.dart';

class RootNav extends StatefulWidget {
  static const routeName = '/root-nav';
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;
  final _pages = const [
    HomeTodayScreen(),
    LearnBasicsScreen(),
    QuestionScreen(),
    ProgressScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Practice'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }
}

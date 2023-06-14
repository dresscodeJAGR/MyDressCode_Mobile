import 'package:flutter/material.dart';
import 'package:mdc/auth/register/register.dart';
import 'package:mdc/pages/dressing.dart';
import 'package:mdc/profile/principalProfile.dart';
import 'package:mdc/home/home.dart';

import 'auth/login/login.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Login(),
      routes: {
        '/register': (context) => const Register(),
        '/main': (context) => const MainWidget(),
      },
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const Dressing(),
    const PrincipalProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 12, // Augmentez la valeur d'élévation pour agrandir la barre de navigation
        unselectedItemColor: Colors.black45,
        selectedFontSize: 14,
        selectedIconTheme: const IconThemeData(size: 30),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            label: 'Dressing',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(79, 125, 88, 1),
        onTap: _onItemTapped,
      ),
    );
  }
}

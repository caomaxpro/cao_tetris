import 'package:flutter/material.dart';
import 'package:tetris_game/screen/multi_mode/multi_screen.dart';
import 'package:tetris_game/screen/settings/settings.dart';
import 'package:tetris_game/screen/single_mode/single_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    MultiScreen(),
    SingleScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Multi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Single',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

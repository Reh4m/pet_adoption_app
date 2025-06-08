import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pet_adoption_app/src/presentation/screens/home/index.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final _pages = <Widget>[const HomeScreen()];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: theme.shadowColor.withAlpha(20)),
          ],
        ),
        child: GNav(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          gap: 20.0,
          backgroundColor: theme.cardColor,
          rippleColor: theme.colorScheme.secondary.withAlpha(20),
          activeColor: theme.colorScheme.secondary,
          tabBackgroundColor: theme.colorScheme.secondary.withAlpha(20),
          color: theme.colorScheme.onSurface,
          duration: const Duration(milliseconds: 250),
          iconSize: 24,
          tabs: const <GButton>[
            GButton(icon: Icons.home_outlined, text: 'Home'),
            GButton(icon: Icons.favorite_outline, text: 'Favorites'),
            GButton(icon: Icons.chat_outlined, text: 'Notifications'),
            GButton(icon: Icons.person_outline, text: 'Profile'),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
    );
  }
}

import 'package:agroconnect/pages/minha_banca.dart';
import 'package:agroconnect/pages/home_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(), // Home page
    SearchPage(), // Search page
    CartPage(), // Cart page
    MinhaBanca(), // Your existing page
    SettingsPage(), // Settings page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromRGBO(84, 157, 115, 1.0),
          unselectedItemColor: Color.fromRGBO(84, 157, 115, 0.6),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 0
                      ? Color.fromRGBO(84, 157, 115, 1.0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/home_nav_icon.svg',
                  height: 26,
                  width: 26,
                  color: _currentIndex == 0 ? Colors.white : Color.fromRGBO(84, 157, 115, 1.0),
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 1
                      ? Color.fromRGBO(84, 157, 115, 1.0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/marketplace_nav_icon.svg',
                  height: 26,
                  width: 26,
                  color: _currentIndex == 1 ? Colors.white : Color.fromRGBO(84, 157, 115, 1.0),
                ),
              ),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 2
                      ? Color.fromRGBO(84, 157, 115, 1.0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/bag_nav_icon.svg',
                  height: 26,
                  width: 26,
                  color: _currentIndex == 2 ? Colors.white : Color.fromRGBO(84, 157, 115, 1.0),
                ),
              ),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 3
                      ? Color.fromRGBO(84, 157, 115, 1.0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/shop_nav_icon.svg',
                  height: 26,
                  width: 26,
                  color: _currentIndex == 3 ? Colors.white : Color.fromRGBO(84, 157, 115, 1.0),
                ),
              ),
              label: 'Minha Banca',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentIndex == 4
                      ? Color.fromRGBO(84, 157, 115, 1.0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  'assets/icons/setting_nav_icon.svg',
                  height: 26,
                  width: 26,
                  color: _currentIndex == 4 ? Colors.white : Color.fromRGBO(84, 157, 115, 1.0),
                ),
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Text(
          'Search Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Center(
        child: Text(
          'Cart Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text(
          'Settings Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
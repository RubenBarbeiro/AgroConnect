import 'package:agroconnect/pages/dashboard.dart';
import 'package:agroconnect/pages/minha_banca.dart';
import 'package:agroconnect/pages/supplier_explore.dart';
import 'package:agroconnect/pages/create_ad.dart';
import 'package:agroconnect/pages/vendas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainNavigationSupplier extends StatefulWidget {
  const MainNavigationSupplier({super.key});

  @override
  State<MainNavigationSupplier> createState() => _MainNavigationSupplierState();
}

class _MainNavigationSupplierState extends State<MainNavigationSupplier> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardPage(),
    //ExploreScreen(),
    SalesScreen(),
    MinhaBanca(),
    CreateAdScreen()
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
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color.fromRGBO(84, 157, 115, 1.0),
            unselectedItemColor: const Color.fromRGBO(84, 157, 115, 0.6),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            items: _buildNavigationItems(),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<BottomNavigationBarItem> _buildNavigationItems() {
    final items = [
      _NavItem('assets/icons/home_nav_icon.svg', 'Home'),
      _NavItem('assets/icons/marketplace_nav_icon.svg', 'Search'),
      _NavItem('assets/icons/bag_nav_icon.svg', 'Cart'),
      _NavItem('assets/icons/shop_nav_icon.svg', 'Compras'),
      _NavItem('assets/icons/setting_nav_icon.svg', 'Settings'),
    ];

    return items.asMap().entries.map((entry) {
      int index = entry.key;
      _NavItem item = entry.value;
      return _buildNavigationItem(item.iconPath, item.label, index);
    }).toList();
  }

  BottomNavigationBarItem _buildNavigationItem(String iconPath, String label, int index) {
    bool isSelected = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(84, 157, 115, 1.0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SvgPicture.asset(
          iconPath,
          height: 26,
          width: 26,
          color: isSelected
              ? Colors.white
              : const Color.fromRGBO(84, 157, 115, 1.0),
        ),
      ),
      label: label,
    );
  }
}

class _NavItem {
  final String iconPath;
  final String label;

  _NavItem(this.iconPath, this.label);
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: const Center(
        child: Text('Search Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text('Settings Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
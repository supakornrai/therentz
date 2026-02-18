import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;

  NavItem(this.icon, this.label);
}

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      items: items
          .map(
            (e) => BottomNavigationBarItem(icon: Icon(e.icon), label: e.label),
          )
          .toList(),
    );
  }
}

// Update staff_home_page.dart
import 'package:flutter/material.dart';
import 'package:the_rentz/components/staff_bottom_nav_bar.dart';
import 'package:the_rentz/pages/inbox_page.dart';
import 'package:the_rentz/pages/profile_page.dart';
import 'package:the_rentz/pages/staff/staff_add_car_page.dart';
import 'package:the_rentz/pages/staff/staff_inventory_page.dart';
import 'package:the_rentz/pages/staff/staff_list_page.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectIndex = 0;

  void navigatorBottomBar(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  
  final List<Widget> _pages = [
    StaffInventoryPage(), 
    StaffAddCarPage(),       
    StaffListPage(), // List: Manage meetings, car
    InboxPage(),         
    ProfliePage(),       
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: StaffBottomNavBar(
        onTapChange: (index) => navigatorBottomBar(index),
      ),
      body: _pages[_selectIndex],
    );
  }
}
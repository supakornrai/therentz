import 'package:flutter/material.dart';
import 'package:the_rentz/pages/admin/admin_dashboard_page.dart';
import 'package:the_rentz/pages/admin/admin_manage_account.dart';
import 'package:the_rentz/pages/admin/admin_report_page.dart';
import 'package:the_rentz/pages/inbox_page.dart';
import 'package:the_rentz/pages/profile_page.dart';
import 'package:the_rentz/services/auth/auth_service.dart';
import 'package:the_rentz/components/admin_bottom_nav_bar.dart'; 

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  void logout() {
    final auth = AuthService();
    auth.signOut();
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    AdminDashboard(), 
    AdminManageAccounts(),    
    AdminReportsPage(),   
    InboxPage(),
    ProfliePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: AdminBottomNavBar(
        onTapChange: (index) => navigateBottomBar(index),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
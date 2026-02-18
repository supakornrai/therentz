import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_rentz/features/admin/account_view.dart';
import 'package:the_rentz/features/admin/inbox_admin_view.dart';
import 'package:the_rentz/features/admin/request_view.dart';
import 'package:the_rentz/features/customer/home_view.dart';
import 'package:the_rentz/features/customer/profile_view.dart';
import 'package:the_rentz/widgets/bottom_nav.dart';

class AdminLayout extends StatefulWidget {
 AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
  final user = FirebaseAuth.instance.currentUser;

}

class _AdminLayoutState extends State<AdminLayout> 
{
  int index = 0;

  final pages = [
    HomeView(),
    AccountView(),
    RequestView(),
    InboxAdminView(),  
    ProfileView(),
  ];

  final navItems = [
    NavItem(Icons.grid_view, 'Home'),
    NavItem(Icons.edit_square, 'Account'),
    NavItem(Icons.priority_high, 'Request'),
    NavItem(Icons.mail, 'inbox'),
    NavItem(Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNav(
        currentIndex: index,
        items: navItems,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

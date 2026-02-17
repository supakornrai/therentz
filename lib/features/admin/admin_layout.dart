import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_rentz/features/customer/favorite_view.dart';
import 'package:the_rentz/features/customer/home_view.dart';
import 'package:the_rentz/features/customer/inbox_view.dart';
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
    FavoriteView(),
    InboxView(),  
    ProfileView(),
  ];

  final navItems = [
    NavItem(Icons.grid_view, 'Home'),
    NavItem(Icons.account_balance, 'Account'),
    NavItem(Icons.request_page, 'Request'),
    NavItem(Icons.inbox, 'inbox'),
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

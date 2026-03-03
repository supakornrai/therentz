import 'package:flutter/material.dart';
import 'package:the_rentz/components/user_bottom_nav_bar.dart';
import 'package:the_rentz/pages/inbox_page.dart';
import 'package:the_rentz/pages/profile_page.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  void logout() {
    //get auth service
    final _auth = AuthService();
    _auth.signOut();
  }

  //naigate bottom bar
  int _selectIndex = 0;
  void navigatorBottomBar(int index) {
    setState(() {
      _selectIndex = index;
    });
  }

  final List<Widget> _pages = [
    const Center(child: Text('home'),),
    const Center(child: Text('fav'),),
    InboxPage(),
    ProfliePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: UserBottomNavBar(
        onTapChange: (index) => navigatorBottomBar(index),
      ),
      body: _pages[_selectIndex],
    );
  }
}

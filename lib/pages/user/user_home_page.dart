import 'package:flutter/material.dart';
import 'package:the_rentz/components/user_bottom_nav_bar.dart';
import 'package:the_rentz/pages/inbox_page.dart';
import 'package:the_rentz/pages/profile_page.dart';
import 'package:the_rentz/pages/user/user_fav.dart';
import 'package:the_rentz/pages/user/user_search.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class UserHomePage extends StatefulWidget {
  UserHomePage({super.key});

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
    UserSearchPage(),
    UserFavPage(),
    InboxPage(),
    ProfilePage(),
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

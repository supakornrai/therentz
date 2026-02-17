import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_rentz/features/customer/favorite_view.dart';
import 'package:the_rentz/features/customer/home_view.dart';
import 'package:the_rentz/features/customer/inbox_view.dart';
import 'package:the_rentz/features/customer/profile_view.dart';
import 'package:the_rentz/widgets/bottom_nav.dart';

class CustomerLayout extends StatefulWidget {
 CustomerLayout({super.key});

  @override
  State<CustomerLayout> createState() => _CustomerLayoutState();
  final user = FirebaseAuth.instance.currentUser;

}

class _CustomerLayoutState extends State<CustomerLayout> 
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
    NavItem(Icons.favorite, 'Favorite'),
    NavItem(Icons.mail, 'Inbox'),
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

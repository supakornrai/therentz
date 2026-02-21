import 'package:flutter/material.dart';
import 'package:the_rentz/features/staff/staff_listing_view.dart';
import 'package:the_rentz/features/staff/staff_inbox_view.dart';
import 'package:the_rentz/features/staff/add_car_view.dart';
import 'package:the_rentz/features/staff/staff_home_view.dart';
import 'package:the_rentz/features/customer/profile_view.dart';
import 'package:the_rentz/widgets/bottom_nav.dart';

class StaffLayout extends StatefulWidget {
  const StaffLayout({super.key});

  @override
  State<StaffLayout> createState() => _StaffLayoutState();
}

class _StaffLayoutState extends State<StaffLayout> {
  int index = 0;

  final pages = [
    StaffHomeView(), 
    AddCarView(),
    StaffListingView(),
    StaffInboxView(),
    ProfileView(),
  ];

  final navItems = [
    NavItem(Icons.grid_view, 'Home'),
    NavItem(Icons.add, 'Add'),
    NavItem(Icons.list, 'Listing'),
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

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class StaffBottomNavBar extends StatelessWidget {
  final Function(int)? onTapChange;

  StaffBottomNavBar({super.key, required this.onTapChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: GNav(
          onTabChange: (value) => onTapChange!(value),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          activeColor: Theme.of(context).colorScheme.primary,
          tabBackgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          tabBorderRadius: 16,
          gap: 6,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          duration: Duration(milliseconds: 400),
          tabs: [
            GButton(icon: Icons.inventory_2_outlined, text: 'Inventory'),
            GButton(icon: Icons.add_circle_outline_rounded, text: 'Add Car'),
            GButton(icon: Icons.list_alt_rounded, text: 'Bookings'),
            GButton(icon: Icons.chat_bubble_outline_rounded, text: 'Inbox'),
            GButton(icon: Icons.person_outline_rounded, text: 'Profile'),
          ],
        ),
      ),
    );
  }
}

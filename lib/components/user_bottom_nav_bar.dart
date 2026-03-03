import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class UserBottomNavBar extends StatelessWidget {
  final Function(int)? onTapChange;
  const UserBottomNavBar({super.key, required this.onTapChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: GNav(
        onTabChange: (value) => onTapChange!(value),
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        color: Theme.of(context).colorScheme.primary,
        activeColor: Theme.of(context).colorScheme.inversePrimary,
        tabBackgroundColor: Theme.of(
          context,
        ).colorScheme.tertiary, 
        tabBorderRadius: 24,
        gap: 6, 
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        tabs: const [
          GButton(icon: Icons.home, text: 'Home'),
          GButton(icon: Icons.favorite, text: 'Favorite'),
          GButton(icon: Icons.inbox, text: 'Inbox'),
          GButton(icon: Icons.person, text: 'Profile'),
        ],
      ),
    );
  }
}

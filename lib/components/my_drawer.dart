import 'package:flutter/material.dart';
import 'package:the_rentz/pages/blocked_users_page.dart';
import 'package:the_rentz/pages/setting_page.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  /// Show Block User menu for admin and staff; hide it for regular users.
  final bool showBlockUser;

  const MyDrawer({super.key, this.showBlockUser = false});

  void logout() {
    final AuthService _authService = AuthService();
    _authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Text(
                'The Rentz',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 30,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: ListTile(
              title: Text("S E T T I N G"),
              leading: Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingPage(showBlockUser: showBlockUser),
                  ),
                );
              },
            ),
          ),

          // Show Block User menu for admin and staff only (not for regular users)
          if (showBlockUser)
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: ListTile(
                title: Text("B L O C K  U S E R"),
                leading: Icon(Icons.block),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlockedUsersPage(),
                    ),
                  );
                },
              ),
            ),

          Spacer(),

          Padding(
            padding: EdgeInsets.only(left: 25, bottom: 25),
            child: ListTile(
              title: Text("L O G O U T"),
              leading: Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}

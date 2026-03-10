import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/pages/setting_page.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
   MyDrawer({super.key});

  void logout() {
    final AuthService authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [

          Container(
            width: double.infinity,
            padding:  EdgeInsets.only(top: 80, bottom: 30, left: 25, right: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 40),
                 SizedBox(height: 20),
                 Text(
                  'The Rentz',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                if (user != null)
                  Text(
                    user.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

           SizedBox(height: 20),

          _buildDrawerItem(
            context,
            icon: Icons.settings_outlined,
            label: "S E T T I N G S",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingPage()),
              );
            },
          ),


           Spacer(),

           Divider(indent: 25, endIndent: 25),

          _buildDrawerItem(
            context,
            icon: Icons.logout_rounded,
            label: "L O G O U T",
            onTap: logout,
            isLogout: true,
          ),

           SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap, bool isLogout = false}) {
    return Padding(
      padding:  EdgeInsets.only(left: 15, right: 15, top: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? Colors.redAccent : Theme.of(context).colorScheme.inversePrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        onTap: onTap,
        hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      ),
    );
  }
}

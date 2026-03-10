import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/pages/admin/admin_home_page.dart';
import 'package:the_rentz/pages/auth/profile_setup_page.dart';
import 'package:the_rentz/pages/staff/staff_home_page.dart';
import 'package:the_rentz/pages/user/user_home_page.dart';
import 'package:the_rentz/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }


        if (!snapshot.hasData) {
          return LoginOrRegister();
        }

        final uid = snapshot.data!.uid;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return ProfileSetupPage(uid: uid);
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;

            String username = data["Username"] ?? "";
            String role = data["Role"] ?? "user";

            if (username.isEmpty) {
              return ProfileSetupPage(uid: uid);
            }
            if (role == "admin") {
              return AdminHomePage();
            }

            if (role == "staff") {
              return StaffHomePage();
            }

            return UserHomePage();
          },
        );
      },
    );
  }
}

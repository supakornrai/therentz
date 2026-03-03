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
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(snapshot.data!.uid)
                  .snapshots(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  
                  String username = userData['Username'] ?? '';
                  if (username.isEmpty) {
                    return ProfileSetupPage(uid: snapshot.data!.uid);
                  }

                  String role = userData['Role'] ?? 'user';
                  if (role == 'admin') {
                    return AdminHomePage();
                  } else if (role == 'staff') {
                    return StaffHomePage();
                  }
                  return UserHomePage();
                }
                
                return ProfileSetupPage(uid: snapshot.data!.uid);
              },
            );
          } else {
            return const LoginOrRegister();
          }
        } 
      ),
    );
  }
}
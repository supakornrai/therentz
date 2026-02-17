import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_or_register_page.dart';
import '../customer/customer_layout.dart';
import '../admin/admin_layout.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const LoginOrRegisterPage();
          }

          final user = snapshot.data!;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
                return Center(child: Text("Loading user data..."));
              }

              final role = roleSnapshot.data!.get('role');

              if (role == 'admin') {
                return AdminLayout();
              } else {
                return CustomerLayout();
              }
            },
          );
        },
      ),
    );
  }
}

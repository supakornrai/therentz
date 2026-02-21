import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:the_rentz/features/auth/auth_page.dart';
import 'package:the_rentz/features/customer/customer_layout.dart';
import 'firebase_options.dart';
import 'package:the_rentz/features/staff/staff_layout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_rentz/features/admin/admin_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return  Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!authSnapshot.hasData) {
            return AuthPage();
          }

          final user = authSnapshot.data!;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return  Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
                return  Scaffold(
                  body: Center(child: Text("User data not found")),
                );
              }

              final role = roleSnapshot.data!['role'];

              if (role == 'admin') {
                return AdminLayout();
              } else if (role == 'staff') {
                return StaffLayout();
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

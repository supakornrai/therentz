import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_rentz/services/auth_service.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text("Profile"), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Text("Username", style: TextStyle()),
            Text("Role", style: TextStyle()),
            Text("Email", style: TextStyle()),
            Text("Phone Number", style: TextStyle()),
            Text("Gender", style: TextStyle()),
            Text("TimeStamp", style: TextStyle()),
            Spacer(),
            
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffHomeView extends StatelessWidget {
  StaffHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          //for check
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          //for check
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          //for check
          if (!snapshot.data!.exists) {
            return Center(child: CircularProgressIndicator());
          }

          //call username in firebase
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'No Name';

          //can't serch just ui
          return Padding(
            padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.search),
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 22, color: Colors.black54),
                ),

                //print username
                Text(
                  username,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

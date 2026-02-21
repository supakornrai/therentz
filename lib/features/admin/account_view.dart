import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Manage Users")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return  Center(child: Text("Error loading users"));
          }

          if (!snapshot.hasData) {
            return  Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return  Center(child: Text("No users found"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final currentRole = user['role'];

              return Card(
                margin:  EdgeInsets.all(10),
                child: ListTile(
                  title: Text(user['username'] ?? "No Name"),
                  subtitle: Text(user['email'] ?? ""),
                  trailing: DropdownButton<String>(
                    value: currentRole,
                    items:  [
                      DropdownMenuItem(
                          value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'staff', child: Text('Staff')),
                      DropdownMenuItem(
                          value: 'customer', child: Text('Customer')),
                    ],
                    onChanged: (newRole) async {
                      if (newRole != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.id)
                            .update({'role': newRole});
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
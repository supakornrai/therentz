import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_drawer.dart';
import 'package:the_rentz/components/text_box.dart';

class ProfliePage extends StatefulWidget {
  ProfliePage({super.key});

  @override
  State<ProfliePage> createState() => _ProfliePageState();
}

class _ProfliePageState extends State<ProfliePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> editField(String field) async {
    String newValue = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Edit " + field, style: TextStyle(color: Colors.white)),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (newValue.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser.uid)
                    .update({field: newValue});
              }
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final userData = (snapshot.hasData && snapshot.data!.data() != null)
            ? snapshot.data!.data() as Map<String, dynamic>
            : null;

        // Determine if the current user is admin or staff → show Block User
        final String role = userData?['Role'] ?? 'user';
        final bool showBlockUser = role == 'admin' || role == 'staff';

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          drawer: MyDrawer(showBlockUser: showBlockUser),
          appBar: AppBar(
            title: Text('Profile'),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey,
            elevation: 0,
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.hasError) {
                return Center(child: Text('Error${snapshot.error}'));
              }
              if (userData == null) {
                return Center(child: CircularProgressIndicator());
              }

              return ListView(
                children: [
                  SizedBox(height: 40),

                  Icon(Icons.person, size: 72),

                  SizedBox(height: 10),

                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 30),

                  MyTextBox(
                    sectionName: 'username',
                    text: userData['Username'],
                    onPressed: () => editField('Username'),
                  ),
                  MyTextBox(
                    sectionName: 'First name',
                    text: userData['Firstname'],
                    onPressed: () => editField('Firstname'),
                  ),
                  MyTextBox(
                    sectionName: 'Last name',
                    text: userData['Lastname'],
                    onPressed: () => editField('Lastname'),
                  ),
                  MyTextBox(
                    sectionName: 'Age',
                    text: userData['Age']?.toString() ?? '0',
                    onPressed: () => editField('Age'),
                  ),
                  MyTextBox(
                    sectionName: 'Gender',
                    text: userData['Gender'] ?? '',
                    onPressed: () => editField('Gender'),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: Row(
                      children: [
                        Text(
                          'Role',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Spacer(),
                        Text(userData['Role'] ?? 'user'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

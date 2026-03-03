import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/text_box.dart';

class ProfliePage extends StatefulWidget {
  const ProfliePage({super.key});

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
        title: Text(
          "Edit " + field,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.grey)
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
          child: const Text('Save'),
        ),
      ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 30),

                //image from user
                Icon(Icons.person, size: 72),

                const SizedBox(height: 10),

                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 30),

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
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_rentz/components/my_drawer.dart';
import 'package:the_rentz/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final cloudinary = CloudinaryPublic(
    "dvphm62a4",
    "unsigned_preset",
    cache: false,
  );

  /// UPLOAD PROFILE IMAGE
  Future<void> uploadProfileImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    File file = File(picked.path);

    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: "profile"),
      );

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(currentUser.uid)
          .update({"Profile_Image": response.secureUrl});
    } catch (e) {
      print(e);
    }
  }

  Future<void> editGender() async {
    String selectedGender = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Gender"),
        content: DropdownButtonFormField<String>(
          hint: Text("Select Gender"),
          items: [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (value) {
            selectedGender = value!;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (selectedGender.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(currentUser.uid)
                    .update({"Gender": selectedGender});
              }
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> editField(String field) async {
    String newValue = '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $field"),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "Enter new $field"),
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

        if (userData == null) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        String profileImage = userData["Profile_Image"] ?? "";

        return Scaffold(
          drawer: MyDrawer(),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        GestureDetector(
                          onTap: uploadProfileImage,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 4),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: Offset(0, 10))
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white24,
                                  backgroundImage: profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
                                  child: profileImage.isEmpty
                                      ? Icon(Icons.person_rounded, size: 50, color: Colors.white)
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Icon(Icons.add_a_photo_rounded, color: Theme.of(context).colorScheme.primary, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          userData['Username'] ?? 'User',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Text(
                          currentUser.email!,
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      /// ACCOUNT INFO SECTION
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Account Information",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      MyTextBox(
                        sectionName: 'Username',
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
                        sectionName: 'Phone Number',
                        text: userData['Phone number'],
                        onPressed: () => editField('Phone number'),
                      ),

                      MyTextBox(
                        sectionName: 'Age',
                        text: userData['Age']?.toString() ?? '',
                        onPressed: () => editField('Age'),
                      ),

                      MyTextBox(
                        sectionName: 'Gender',
                        text: userData['Gender'] ?? '',
                        onPressed: editGender,
                      ),

                      /// ROLE SECTION
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
                          ],
                        ),
                        padding: EdgeInsets.all(20),
                        margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.verified_user_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Account Role",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                userData["Role"].toString().toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

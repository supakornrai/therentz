import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_rentz/services/storage_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileView extends StatefulWidget {
  ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageService _storageService = StorageService();

  bool isEditMode = false;
  bool isSaving = false;

  final TextEditingController phoneController = TextEditingController();
  String? selectedGender;
  String? photoUrl;

  /// load data from firestore to controller
  void _loadUserData(Map<String, dynamic> data) {
    phoneController.text = data["phone"] ?? "";
    selectedGender = data["gender"];
    photoUrl = data["pictureURL"];
  }

  //image.picker
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    File file = File(picked.path);
    String newUrl = await _storageService.uploadProfileImage(file);

    setState(() {
      photoUrl = newUrl;
    });
  }

  //save profile
  Future<void> _saveProfile() async {
    if (user == null) return;

    String phone = phoneController.text.trim();

    //only number
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone number must contain digits only")),
      );
      return;
    }

    //check phone number
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Phone number must be exactly 10 digits")),
      );
      return;
    }

    setState(() => isSaving = true);

    await _firestore.collection("users").doc(user!.uid).update({
      "phone": phone,
      "gender": selectedGender,
      "pictureURL": photoUrl,
    });

    setState(() {
      isSaving = false;
      isEditMode = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Profile updated successfully")));
  }

  //logout
  Future<void> _logout() async {
    final googleSignIn = GoogleSignIn();

    try {
      await googleSignIn.signOut();
    } catch (e) {
      print("Google sign out error: $e");
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("users").doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          if (!isEditMode) {
            _loadUserData(data);
          }

          return _buildBody(data);
        },
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          _buildProfileImage(),
          SizedBox(height: 16),

          Text(
            data["username"] ?? "User",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          Text(
            data["role"] ?? "customer",
            style: TextStyle(color: Colors.grey),
          ),

          SizedBox(height: 30),

          _buildField("Email", data["email"] ?? user!.email),

          isEditMode
              ? _buildTextField("Phone Number", phoneController)
              : _buildField("Phone Number", data["phone"]),

          isEditMode
              ? _buildGenderDropdown()
              : _buildField("Gender", data["gender"]),

          SizedBox(height: 30),

          if (isEditMode) _buildSaveButton(),

          SizedBox(height: 40),

          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null ? Icon(Icons.person, size: 55) : null,
        ),
        if (isEditMode)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue,
                child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildField(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value ?? "-"),
        ),
        SizedBox(height: 18),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        SizedBox(height: 18),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      items: ["Male", "Female", "LGBTQ+"]
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedGender = value;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveProfile,
        child: isSaving
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text("Save Changes"),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        onPressed: _logout,
        child: Text("Log out"),
      ),
    );
  }
}

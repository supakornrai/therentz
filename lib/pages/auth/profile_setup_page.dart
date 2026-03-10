import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_button.dart';
import 'package:the_rentz/components/my_textfield.dart';
import 'package:the_rentz/enum.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class ProfileSetupPage extends StatefulWidget {
  final String uid;
  ProfileSetupPage({super.key, required this.uid});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _usernameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _pnumberController = TextEditingController();

  String _selectedGender = 'Male';
  final List<String> _genders = ['Male', 'Female', 'Other'];

  void saveProfile() async {
    try {
      if (_usernameController.text.isEmpty ||
          _firstnameController.text.isEmpty ||
          _lastnameController.text.isEmpty ||
          _ageController.text.isEmpty
          || _pnumberController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Please fill in all fields")));
        return;
      }

      await AuthService().updateAdditionalProfileInfo(
        uid: widget.uid,
        username: _usernameController.text.trim(),
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
        phoneNumber: _pnumberController.text.trim(),
        role: AppRole.user,
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        imageUrl: "",
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String name = user.displayName ?? "";

      if (name.isNotEmpty) {
        List parts = name.split(" ");

        _usernameController.text = name;
        _firstnameController.text = parts.first;

        if (parts.length > 1) {
          _lastnameController.text = parts.sublist(1).join(" ");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            children: [
              Text(
                "Complete Profile",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: 25),

              MyTextField(
                controller: _usernameController,
                labelText: "Username",
                hintText: "Enter username",
                obscureText: false,
              ),
              SizedBox(height: 10),

              MyTextField(
                controller: _firstnameController,
                labelText: "First Name",
                hintText: "Enter first name",
                obscureText: false,
              ),
              SizedBox(height: 10),

              MyTextField(
                controller: _lastnameController,
                labelText: "Last Name",
                hintText: "Enter last name",
                obscureText: false,
              ),
              SizedBox(height: 10),

              MyTextField(
                controller: _ageController,
                labelText: "Age",
                hintText: "Enter age",
                obscureText: false,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),

              MyTextField(
                controller: _pnumberController,
                labelText: "Phone Number",
                hintText: "Enter Phone Number",
                obscureText: false,
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: "Gender",
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.secondary,
                ),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),

              SizedBox(height: 30),

              MyButton(onTap: saveProfile, text: "Complete Register"),
            ],
          ),
        ),
      ),
    );
  }
}

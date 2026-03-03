import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_button.dart';
import 'package:the_rentz/components/my_textfield.dart';
import 'package:the_rentz/enum.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class ProfileSetupPage extends StatefulWidget {
  final String uid;
  const ProfileSetupPage({super.key, required this.uid});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  
  AppRole _selectedRole = AppRole.user;
  String _selectedGender = 'Male';
  
  final List<AppRole> _roles = [AppRole.user, AppRole.staff];
  final List<String> _genders = ['Male', 'Female', 'Other'];

  void saveProfile() async {
  try {
    if (_usernameController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields"))
      );
      return;
    }

    await AuthService().updateAdditionalProfileInfo(
      uid: widget.uid,
      username: _usernameController.text.trim(),
      role: _selectedRole,
      age: int.parse(_ageController.text.trim()),
      gender: _selectedGender,
      imageUrl: "", 
    );
    
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e"))
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
          child: Column(
            children: [
              Text("Complete Profile", style: TextStyle(fontSize: 24, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 25),

              MyTextField(controller: _usernameController, hintText: "Username", obscureText: false),
              const SizedBox(height: 15),
              
              MyTextField(controller: _ageController, hintText: "Age", obscureText: false),
              const SizedBox(height: 15),

              DropdownButtonFormField<AppRole>(
                initialValue: _selectedRole,
                decoration: InputDecoration(labelText: "Select Role", filled: true, fillColor: Theme.of(context).colorScheme.secondary),
                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: _selectedGender,
                decoration: InputDecoration(labelText: "Gender", filled: true, fillColor: Theme.of(context).colorScheme.secondary),
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGender = val!),
              ),

              const SizedBox(height: 30),
              MyButton(onTap: saveProfile, text: "Finish Setup"),
            ],
          ),
        ),
      ),
    );
  }
}
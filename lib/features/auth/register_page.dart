import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/widgets/my_button.dart';
import 'package:the_rentz/widgets/my_textfield.dart';
import 'package:the_rentz/widgets/square_button.dart';
import 'package:the_rentz/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final userNameController = TextEditingController();

  void signUserUp() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      //Validation
      if (passwordController.text != confirmPasswordController.text) {
        Navigator.pop(context);
        showErrorMessage("Passwords don't match");
        return;
      }

      //call AuthService for register
      await AuthService().register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: userNameController.text.trim(),
      );

    //catching error
    } on FirebaseAuthException catch (e) {
      showErrorMessage(_mapErrorMessage(e.code));
    } catch (e) {
      showErrorMessage("Something went wrong");
    }

    if (mounted) Navigator.pop(context);
  }

  //fix error 
  String _mapErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email format';
      default:
        return 'Registration failed';
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Text(message, style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),

              Text("Sign Up", style: TextStyle(fontSize: 30)),

              SizedBox(height: 25),

              MyTextField(
                controller: userNameController,
                hintText: 'Username',
                obscureText: false,
              ),

              SizedBox(height: 10),

              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),

              SizedBox(height: 15),

              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 10),

              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),

              SizedBox(height: 25),

              MyButton(onTap: signUserUp, text: "Sign Up"),

              SizedBox(height: 40),

              //Google login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareButton(
                    onTap: () => AuthService().signInWithGoogle(),
                    imagePath: 'assets/images/google (1).png',
                  ),
                ],
              ),

              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

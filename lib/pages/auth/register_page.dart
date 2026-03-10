import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_button.dart';
import 'package:the_rentz/components/my_textfield.dart';
import 'package:the_rentz/components/square_button.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void register(BuildContext context) async {
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        await AuthService().signUpWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text('Passwords don\'t match')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Icon(
                  Icons.car_rental_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),

                SizedBox(height: 25),
                Text(
                  "Let's create an account",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),

                SizedBox(height: 25),
                MyTextField(
                  controller: _emailController,
                  labelText: "Email",
                  hintText: "Enter your email",
                  obscureText: false,
                ),

                SizedBox(height: 10),
                MyTextField(
                  controller: _passwordController,
                  labelText: "Password",
                  hintText: "Create password",
                  obscureText: true,
                ),

                SizedBox(height: 10),

                // Confirm Password Input
                MyTextField(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password",
                  hintText: "Re-enter password",
                  obscureText: true,
                ),

                SizedBox(height: 25),

                // Submit Button
                MyButton(onTap: () => register(context), text: 'Register'),

                SizedBox(height: 25),

                // Login Route Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50),

                // OAuth Divider
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or Login with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(thickness: 0.5, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),

                // Google OAuth Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareButton(
                      onTap: () => AuthService().signInWithGoogle(),
                      imagePath: 'assets/images/google (1).png',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

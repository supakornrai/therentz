import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_button.dart';
import 'package:the_rentz/components/my_textfield.dart';
import 'package:the_rentz/components/square_button.dart';
import 'package:the_rentz/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //email & pasword controller
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController = TextEditingController();

  // register method
  void register(BuildContext context) async {

    // password match -> create a user
    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        AuthService().signUpWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );
        
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }
    // password does not match -> tell user
    else {
      showDialog(
        context: context,
        builder: (context) =>
            const AlertDialog(title: Text('Password don\'t match')),
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
                //logo
                Icon(
                  Icons.car_rental_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
          
                const SizedBox(height: 25),
          
                //welcome back message
                Text(
                  "Let's create a account",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
          
                const SizedBox(height: 25),
          
                //email textfield
                MyTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
          
                const SizedBox(height: 10),
          
                //pw textfield
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
          
                const SizedBox(height: 10),
          
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
          
                const SizedBox(height: 25),
          
                //login button
                MyButton(onTap: () => register(context), text: 'Register'),
          
                const SizedBox(height: 25),
          
                //register??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account ',
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
          
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(thickness: 0.5, color: Colors.grey[400]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
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

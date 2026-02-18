import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_button.dart';
import 'package:the_rentz/components/my_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  final Function()? onTap;
  const ForgotPasswordPage({super.key, this.onTap});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
       showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text('Password reset link sent. Please check your Email'),
          );
        }
        );
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        }
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: 
              Text(
                'Please enter your Email to reset password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20
                ),
                ),
            ),
            
            SizedBox(height: 10),
        
            MyTextField(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
            ),
        
            SizedBox(height: 10),
        
            MyButton(
              onTap: resetPassword, 
              text: 'Reset password')
          ],
        ),
      ),
    );
  }
}
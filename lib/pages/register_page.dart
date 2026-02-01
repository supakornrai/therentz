import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_button.dart';
import 'package:the_rentz/components/my_textfield.dart';
import 'package:the_rentz/components/square_button.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  final userNameController = TextEditingController();

  //sign user in
  void signUserUp() async {

    showDialog(
      context: context, 
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text
          );
      } else {
        Navigator.pop(context);
        showErrorMessage("Password don't match");
      }
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }
    void showErrorMessage(String message) {
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            title: Center(
              child: Text(
                message,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
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
              Text(
                "Sign Up",
                style: TextStyle(color: Colors.grey[900],
                fontSize: 30),
              ),

              SizedBox(height: 10),

              Text(
                "Create an account to get started ",
                style: TextStyle(color: Colors.grey[700],
                fontSize: 15),
              ),

              SizedBox(height: 25),
              
              //username
              MyTextField(
                controller: userNameController,
                hintText: 'Username',
                obscureText: false,
              ),

              SizedBox(height: 10),
              
              //email
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
          
              SizedBox(height: 15),
          
              //password
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              SizedBox(height: 10),

              //confirm password
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Password',
                obscureText: true,
              ),
             
              SizedBox(height: 25),
          
              MyButton(
                onTap: signUserUp,
                text: "Sign Up",
              ),
          
              SizedBox(height: 40),
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or Sign In with',
                        style: TextStyle(color: Colors.grey[700]),
                        ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
          
              SizedBox(height: 40,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareButton(imagePath: 'assets/images/google (1).png')
                ],
              ),
          
              SizedBox(height: 40,),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(width: 4,),
                  GestureDetector(
                    onTap : widget.onTap,
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      )
    );
  }
}
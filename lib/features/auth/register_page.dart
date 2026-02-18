import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/services/auth_service.dart';

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

  void signUserUp() async {
    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (passwordController.text.trim() !=
          confirmPasswordController.text.trim()) {
        Navigator.pop(context);
        showErrorMessage("Passwords don't match");
        return;
      }

      await AuthService().register(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: userNameController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(_mapErrorMessage(e.code));
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage("Something went wrong. Please try again.");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Register Failed"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _mapErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return "Email is already registered.";
      case 'invalid-email':
        return "Invalid email format.";
      case 'weak-password':
        return "Password must be at least 6 characters.";
      default:
        return "Registration failed. Please try again.";
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Text(
                "Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: userNameController,
                decoration: const InputDecoration(hintText: "Username"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "Email"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Password"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Confirm Password"),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: signUserUp,
                child: const Text("Sign Up"),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Login now",
                      style: TextStyle(fontWeight: FontWeight.bold),
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

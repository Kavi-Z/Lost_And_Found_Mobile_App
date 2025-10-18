import 'package:flutter/material.dart';
import 'package:lost_found/screens/auth/signup_screen.dart';
import 'package:lost_found/widgets/custom_textfield.dart';
import 'package:lost_found/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back 👋",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login to your account",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                controller: emailController,
                hintText: "Email",
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 30),

              CustomButton(
                text: isLoading ? "Logging in..." : "Login",
                onPressed: () async {
                  setState(() => isLoading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  setState(() => isLoading = false);
                  // TODO: Add Firebase Auth login here
                },
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
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

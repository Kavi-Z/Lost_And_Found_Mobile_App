import 'package:flutter/material.dart';
import 'package:lost_found/screens/auth/signup_screen.dart';
import 'package:lost_found/widgets/custom_textfield.dart';
import 'package:lost_found/widgets/custom_button.dart';
import 'package:lost_found/widgets/loading_indicator.dart'; // import the loading indicator

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    opacity: _fadeAnimation.value,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Welcome Back 👋",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                            text: "Login",
                            onPressed: () async {
                              setState(() => isLoading = true);
                              await Future.delayed(const Duration(seconds: 1));
                              setState(() => isLoading = false);
                              // TODO: Add Firebase Auth login
                            },
                          ),

                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account? ",
                                style: TextStyle(color: Colors.black87),
                              ),
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
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

       
        if (isLoading)
          const LoadingIndicator(message: "Logging in..."),
      ],
    );
  }
}

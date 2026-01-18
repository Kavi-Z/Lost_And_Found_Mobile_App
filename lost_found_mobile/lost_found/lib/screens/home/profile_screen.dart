import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController passwordController = TextEditingController();
  bool changingPassword = false;
  bool signingOut = false;

  @override
  void initState() {
    super.initState();
    _redirectIfNotLoggedIn();
  }

  void _redirectIfNotLoggedIn() {
    if (user == null) {
      // User not logged in → redirect to login immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    if (user == null) return; // Extra safety

    if (passwordController.text.trim().length < 6) {
      toastification.show(
        context: context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        title: const Text("Weak Password"),
        description: const Text("Password must be at least 6 characters."),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12),
      );
      return;
    }

    setState(() => changingPassword = true);

    try {
      await user!.updatePassword(passwordController.text.trim());
      toastification.show(
        context: context,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: const Text("Password Updated"),
        description: const Text("Your password has been changed."),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12),
      );
      passwordController.clear();
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text("Password Change Failed"),
        description: Text("$e"),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12),
      );
    }

    setState(() => changingPassword = false);
  }

  Future<void> signOut() async {
    if (user == null) return;

    setState(() => signingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: const Text("Sign Out Failed"),
        description: Text("$e"),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 3),
        borderRadius: BorderRadius.circular(12),
      );
    }
    setState(() => signingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Password Field
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "New Password",
                        labelStyle: const TextStyle(color: Colors.white),
                        hintStyle: const TextStyle(color: Colors.white54),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white54),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Change Password Button
                    changingPassword
                        ? const CircularProgressIndicator(color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 32),
                    // Sign Out Button
                    signingOut
                        ? const CircularProgressIndicator(color: Colors.white)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signOut,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Sign Out",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}

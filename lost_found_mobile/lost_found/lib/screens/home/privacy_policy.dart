import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color.fromARGB(255, 250, 250, 250),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Data Collection"),
            _sectionContent(
                "We collect information you provide directly to us when you create an account, report a lost item, or update your profile. This includes your name, email, and phone number."),
            _sectionTitle("How We Use Data"),
            _sectionContent(
                "We use your contact information solely to facilitate the connection between people who have lost items and those who have found them."),
            _sectionTitle("Image Privacy"),
            _sectionContent(
                "Images uploaded to the platform are public to help identify lost items. Please do not upload sensitive personal documents."),
            _sectionTitle("Contact Visibility"),
            _sectionContent(
                "Your phone number is visible to other users only when you explicitly list it on a lost or found item report."),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Last updated: Jan 2026',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionContent(String content) {
    return Text(
      content,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}

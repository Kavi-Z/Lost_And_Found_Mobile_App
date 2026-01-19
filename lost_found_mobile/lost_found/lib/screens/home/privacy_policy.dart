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
            // Introduction
            Text(
              'Effective Date: January 2025',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to Lost & Found App. Your privacy is important to us.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 8),

            // Section 1
            _sectionTitle("1. Data Collection"),
            _sectionContent(
              "We collect information you provide directly to us when you create an account, report a lost item, or update your profile. This includes your name, email, and phone number.",
            ),

            // Section 2
            _sectionTitle("2. How We Use Data"),
            _sectionContent(
              "We use your contact information solely to facilitate the connection between people who have lost items and those who have found them.",
            ),

            // Section 3
            _sectionTitle("3. Image Privacy"),
            _sectionContent(
              "Images uploaded to the platform are public to help identify lost items. Please do not upload sensitive personal documents.",
            ),

            // Section 4
            _sectionTitle("4. Contact Visibility"),
            _sectionContent(
              "Your phone number is visible to other users only when you explicitly list it on a lost or found item report.",
            ),

            // Section 5
            _sectionTitle("5. Data Storage"),
            _sectionContent(
              "Your data is stored securely on Google Firebase servers. We use industry-standard encryption to protect your information.",
            ),

            // Section 6
            _sectionTitle("6. Data Retention"),
            _sectionContent(
              "We keep your data while your account is active. Item reports marked as resolved are deleted after 90 days automatically.",
            ),

            // Section 7
            _sectionTitle("7. Third-Party Services"),
            _sectionContent(
              "We use Firebase for login and database, and Cloudinary for image storage. These services follow their own privacy policies.",
            ),

            // Section 8
            _sectionTitle("8. Location Information"),
            _sectionContent(
              "We only collect location when you add it to an item report. We never track your location in the background.",
            ),

            // Section 9
            _sectionTitle("9. Account Security"),
            _sectionContent(
              "Keep your password safe and private. Use a strong password with letters, numbers, and symbols. Never share your login details.",
            ),

            // Section 10
            _sectionTitle("10. Children's Privacy"),
            _sectionContent(
              "This app is not for children under 13 years old. We do not knowingly collect information from children.",
            ),

            // Section 11
            _sectionTitle("11. Data Sharing"),
            _sectionContent(
              "We never sell or rent your personal data. We only share data when required by law or to protect user safety.",
            ),

            // Section 12
            _sectionTitle("12. Your Rights"),
            _sectionContent(
              "You can view, edit, download, or delete your personal data anytime. Go to Profile Settings to manage your information.",
            ),

            // Section 13
            _sectionTitle("13. Account Deletion"),
            _sectionContent(
              "You can delete your account from Profile Settings. All your data will be permanently removed within 30 days.",
            ),

            // Section 14
            _sectionTitle("14. Cookies"),
            _sectionContent(
              "We use essential cookies to keep you logged in. We do not use cookies for advertising or tracking.",
            ),

            // Section 15
            _sectionTitle("15. Notifications"),
            _sectionContent(
              "We may send you notifications about your items or account. You can turn off notifications in your device settings.",
            ),

            // Section 16
            _sectionTitle("16. Policy Updates"),
            _sectionContent(
              "We may update this policy from time to time. We will notify you of any major changes through the app or email.",
            ),

            // Section 17
            _sectionTitle("17. Disclaimer"),
            _sectionContent(
              "We are not responsible for items lost, stolen, or damaged. Users are responsible for verifying item ownership before returning.",
            ),

            // Section 18
            _sectionTitle("18. Contact Us"),
            _sectionContent(
              "For any privacy questions or concerns, please email us at support@lostandfound.app. We respond within 48 hours.",
            ),

            const SizedBox(height: 32),

            // Agreement Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green[400]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By using this app, you agree to this Privacy Policy.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Lost & Found App',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last updated: January 2025',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
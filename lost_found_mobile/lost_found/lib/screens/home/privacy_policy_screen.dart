import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Privacy P',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Your privacy is important to us',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          _buildSectionWithIcon(
            Icons.person_outline,
            'Data Collection',
            'We collect your name, email, and phone when you create an account.',
          ),
          _buildSectionWithIcon(
            Icons.data_usage_outlined,
            'How We Use Data',
            'Your info helps connect people who lost items with finders.',
          ),
          _buildSectionWithIcon(
            Icons.image_outlined,
            'Image Privacy',
            'Uploaded images are public. Avoid uploading sensitive documents.',
          ),
          _buildSectionWithIcon(
            Icons.phone_outlined,
            'Contact Visibility',
            'Phone is visible only when you list it on a report.',
          ),
          _buildSectionWithIcon(
            Icons.security_outlined,
            'Data Security',
            'We protect your data using industry-standard encryption.',
          ),
          _buildSectionWithIcon(
            Icons.delete_outline,
            'Data Deletion',
            'Request deletion anytime via Profile settings.',
          ),
          _buildSectionWithIcon(
            Icons.cloud_outlined,
            'Third-Party Services',
            'We use Firebase for authentication and data storage.',
          ),
          _buildSectionWithIcon(
            Icons.location_on_outlined,
            'Location Information',
            'We collect location only when you provide it for reports.',
          ),
          _buildSectionWithIcon(
            Icons.cookie_outlined,
            'Cookies',
            'We use essential cookies only. No tracking for ads.',
          ),
          _buildSectionWithIcon(
            Icons.child_care_outlined,
            'Children\'s Privacy',
            'Our service is not intended for children under 13.',
          ),
          _buildSectionWithIcon(
            Icons.share_outlined,
            'Data Sharing',
            'We do not sell your personal information to anyone.',
          ),
          _buildSectionWithIcon(
            Icons.verified_user_outlined,
            'User Rights',
            'You can access, correct, or delete your data anytime.',
          ),
          _buildSectionWithIcon(
            Icons.update_outlined,
            'Policy Updates',
            'Users will be notified of significant policy changes.',
          ),
          _buildSectionWithIcon(
            Icons.email_outlined,
            'Contact Us',
            'Email us at privacy@lostandfound.app for any questions.',
          ),

          const SizedBox(height: 32),

          // Contact Box
          _buildContactBox(),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Last updated: January 2026',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionWithIcon(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.help_outline, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Have Questions?',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contact us at privacy@lostandfound.app',
                  style: TextStyle(color: Colors.blue[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
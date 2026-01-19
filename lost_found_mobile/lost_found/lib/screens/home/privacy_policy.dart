import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  final List<Map<String, dynamic>> _sections = const [
    {
      'icon': Icons.lock_outline,
      'title': 'Data We Collect',
      'content': 'We collect your name, email, and phone number when you create an account.',
    },
    {
      'icon': Icons.visibility_outlined,
      'title': 'Data Visibility',
      'content': 'Your contact info is only visible when you add it to an item report.',
    },
    {
      'icon': Icons.cloud_outlined,
      'title': 'Data Security',
      'content': 'Your data is encrypted and stored securely on Firebase servers.',
    },
    {
      'icon': Icons.share_outlined,
      'title': 'Data Sharing',
      'content': 'We never sell your data. We only share when required by law.',
    },
    {
      'icon': Icons.delete_outline,
      'title': 'Data Deletion',
      'content': 'You can delete your account anytime. All data is removed within 30 days.',
    },
    {
      'icon': Icons.location_on_outlined,
      'title': 'Location',
      'content': 'We only collect location when you add it to reports. No background tracking.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Privacy Policy'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Privacy Matters',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated: January 2025',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sections
          ..._sections.map((section) => _buildSection(
                icon: section['icon'],
                title: section['title'],
                content: section['content'],
              )),

          const SizedBox(height: 16),

          // Contact
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.mail_outline, color: Colors.grey[500], size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Questions?', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('support@lostandfound.app', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Agreement
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By using this app, you agree to this privacy policy.',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
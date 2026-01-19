import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final user = FirebaseAuth.instance.currentUser;
  bool signingOut = false;

  @override
  void initState() {
    super.initState();
    _redirectIfNotLoggedIn();
  }

  void _redirectIfNotLoggedIn() {
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
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
      _showToast("Sign Out Failed", "$e", ToastificationType.error);
    }
    setState(() => signingOut = false);
  }

  void _showToast(String title, String message, ToastificationType type) {
    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(title),
      description: Text(message),
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  
                  _buildProfileCard(),
                  const SizedBox(height: 24),

                
                  _buildStatsSection(),
                  const SizedBox(height: 24),
 
                  _buildMenuSection(),
                  const SizedBox(height: 24),
 
                  _buildSignOutButton(),
                  const SizedBox(height: 16),
 
                  _buildDeleteAccountButton(),
                  const SizedBox(height: 32),
 
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ============ PROFILE CARD ============
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.emailVerified == true ? 'Verified' : 'Not Verified',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 // ============ STATS SECTION ============  
Widget _buildStatsSection() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('items')
        .where('userId', isEqualTo: user?.uid)
        .snapshots(),
    builder: (context, snapshot) {
      int totalItems = 0;
      int resolvedItems = 0;
      int lostItems = 0;
      int foundItems = 0;

      if (snapshot.hasData) {
        final docs = snapshot.data!.docs;
        totalItems = docs.length;
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['isResolved'] == true) resolvedItems++;
          if (data['type'] == 'Lost') lostItems++;
          if (data['type'] == 'Found') foundItems++;
        }
      }

      return Row(
        children: [
          _buildStatCard('Posted', '$totalItems', Icons.post_add),
          const SizedBox(width: 12),
          _buildStatCard('Resolved', '$resolvedItems', Icons.check_circle_outline, bgColor: Colors.green[900], iconColor: Colors.green[300]),
          const SizedBox(width: 12),
          _buildStatCard('Lost', '$lostItems', Icons.search_off),
          const SizedBox(width: 12),
          _buildStatCard('Found', '$foundItems', Icons.search),
        ],
      );
    },
  );
}

Widget _buildStatCard(String label, String value, IconData icon, {Color? bgColor, Color? iconColor}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? Colors.grey[500], size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    ),
  );
}


  // ============ MENU SECTION ============
  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Change your name',
          onTap: () => _showEditNameDialog(),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your password',
          onTap: () => _showChangePasswordDialog(),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.inventory_2_outlined,
          title: 'My Items',
          subtitle: 'View your posted items',
          onTap: () => Navigator.pushNamed(context, '/my-items'),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help or contact us',
          onTap: () => _showHelpDialog(),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () => Navigator.pushNamed(context, '/privacy'),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }

  // ============ SIGN OUT BUTTON ============
  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: signingOut ? null : () => _showSignOutDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: signingOut
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              )
            : const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  // ============ DELETE ACCOUNT BUTTON ============
  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => _showDeleteAccountDialog(),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Delete Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ============ DIALOGS ============

  void _showEditNameDialog() {
    final controller = TextEditingController(text: user?.displayName ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.grey[500]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await user?.updateDisplayName(controller.text.trim());
                Navigator.pop(ctx);
                setState(() {});
                _showToast('Success', 'Name updated', ToastificationType.success);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new password',
            hintStyle: TextStyle(color: Colors.grey[500]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[700]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().length >= 6) {
                try {
                  await user?.updatePassword(controller.text.trim());
                  Navigator.pop(ctx);
                  _showToast('Success', 'Password updated', ToastificationType.success);
                } catch (e) {
                  _showToast('Error', '$e', ToastificationType.error);
                }
              } else {
                _showToast('Error', 'Password must be 6+ characters', ToastificationType.warning);
              }
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              signOut();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete user items first
                final items = await FirebaseFirestore.instance
                    .collection('items')
                    .where('userId', isEqualTo: user?.uid)
                    .get();

                for (var doc in items.docs) {
                  await doc.reference.delete();
                }

                // Delete user account
                await user?.delete();
                Navigator.of(ctx).pushReplacementNamed('/login');
                _showToast('Account Deleted', 'Your account has been deleted', ToastificationType.success);
              } catch (e) {
                Navigator.pop(ctx);
                _showToast('Error', '$e', ToastificationType.error);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help & Support', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(Icons.email_outlined, 'Email', 'support@lostandfound.app'),
            const SizedBox(height: 16),
            _buildHelpItem(Icons.phone_outlined, 'Phone', '+1 234 567 890'),
            const SizedBox(height: 16),
            _buildHelpItem(Icons.access_time, 'Hours', 'Mon-Fri, 9AM-5PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
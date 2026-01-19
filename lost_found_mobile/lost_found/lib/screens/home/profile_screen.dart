import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import '../auth/login_screen.dart';

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  User? user = FirebaseAuth.instance.currentUser;
  bool signingOut = false, deletingAccount = false;

  @override
  void initState() {
    super.initState();
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigateToLogin());
    }
  }

  void _navigateToLogin() => Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);

  void _showToast(String title, String msg, ToastificationType type) {
    toastification.show(
      context: context, type: type, style: ToastificationStyle.flat,
      title: Text(title), description: Text(msg), alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3), borderRadius: BorderRadius.circular(12),
    );
  }

  Future<void> signOut() async {
    if (user == null) return;
    setState(() => signingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        _showToast("Success", "Signed out successfully", ToastificationType.success);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) _navigateToLogin();
      }
    } catch (e) {
      if (mounted) {
        setState(() => signingOut = false);
        _showToast("Sign Out Failed", "$e", ToastificationType.error);
      }
    }
  }

  // ============ REUSABLE STYLES ============
  InputDecoration _inputDecoration(String hint, {Color borderColor = Colors.white}) => InputDecoration(
    hintText: hint, hintStyle: TextStyle(color: Colors.grey[500]),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!), borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: borderColor), borderRadius: BorderRadius.circular(12)),
  );

  AlertDialog _buildDialog({required String title, required Widget content, required List<Widget> actions, Color? titleColor}) =>
    AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: TextStyle(color: titleColor ?? Colors.white)),
      content: content, actions: actions,
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Profile"), backgroundColor: Colors.black, centerTitle: true, elevation: 0),
      body: user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                _buildProfileCard(),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildMenuSection(),
                const SizedBox(height: 24),
                _buildActionButton('Sign Out', Colors.white, Colors.black, signingOut, _showSignOutDialog),
                const SizedBox(height: 16),
                _buildActionButton('Delete Account', Colors.transparent, Colors.red, deletingAccount, _showDeleteAccountDialog, isOutlined: true),
                const SizedBox(height: 32),
                Text('Version 1.0.0', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 20),
              ]),
            ),
    );
  }

  // ============ PROFILE CARD ============
  Widget _buildProfileCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(
        width: 70, height: 70,
        decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person, color: Colors.white, size: 36),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(user?.displayName ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(user?.email ?? 'No email', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: user?.emailVerified == true ? Colors.green[900] : Colors.orange[900],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user?.emailVerified == true ? 'Verified' : 'Not Verified',
            style: TextStyle(color: user?.emailVerified == true ? Colors.green[300] : Colors.orange[300], fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ])),
    ]),
  );

  // ============ STATS SECTION ============
  Widget _buildStatsSection() => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('items').where('userId', isEqualTo: user?.uid).snapshots(),
    builder: (context, snapshot) {
      int total = 0, resolved = 0, lost = 0, found = 0;
      if (snapshot.hasData) {
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          total++;
          if (data['isResolved'] == true) resolved++;
          if (data['type'] == 'Lost') lost++;
          if (data['type'] == 'Found') found++;
        }
      }
      return Row(children: [
        _buildStatCard('Posted', '$total', Icons.post_add),
        const SizedBox(width: 12),
        _buildStatCard('Resolved', '$resolved', Icons.check_circle_outline),
        const SizedBox(width: 12),
        _buildStatCard('Lost', '$lost', Icons.search_off),
        const SizedBox(width: 12),
        _buildStatCard('Found', '$found', Icons.search),
      ]);
    },
  );

  Widget _buildStatCard(String label, String value, IconData icon) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ]),
    ),
  );

  // ============ MENU SECTION ============
  Widget _buildMenuSection() => Column(children: [
    _buildMenuItem(Icons.person_outline, 'Edit Profile', 'Change your name', _showEditNameDialog),
    const SizedBox(height: 12),
    _buildMenuItem(Icons.lock_outline, 'Change Password', 'Update your password', _showChangePasswordDialog),
    const SizedBox(height: 12),
    _buildMenuItem(Icons.inventory_2_outlined, 'My Items', 'View your posted items', () => Navigator.pushNamed(context, '/my-items')),
    const SizedBox(height: 12),
    _buildMenuItem(Icons.help_outline, 'Help & Support', 'Get help or contact us', _showHelpDialog),
    const SizedBox(height: 12),
    _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'Read our privacy policy', () => Navigator.pushNamed(context, '/privacy')),
  ]);

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ])),
        Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
      ]),
    ),
  );

  // ============ ACTION BUTTONS ============
  Widget _buildActionButton(String text, Color bg, Color fg, bool loading, VoidCallback onTap, {bool isOutlined = false}) => SizedBox(
    width: double.infinity, height: 56,
    child: isOutlined
        ? OutlinedButton(
            onPressed: loading ? null : onTap,
            style: OutlinedButton.styleFrom(foregroundColor: fg, side: BorderSide(color: fg, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: loading ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: fg, strokeWidth: 2)) : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        : ElevatedButton(
            onPressed: loading ? null : onTap,
            style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: fg, disabledBackgroundColor: Colors.grey[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: loading ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: fg, strokeWidth: 2)) : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
  );

  // ============ DIALOGS ============
  void _showEditNameDialog() {
    final controller = TextEditingController(text: user?.displayName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => _buildDialog(
        title: 'Edit Name',
        content: TextField(controller: controller, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Enter your name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) { _showToast('Error', 'Name cannot be empty', ToastificationType.warning); return; }
              try {
                await user?.updateDisplayName(controller.text.trim());
                await user?.reload();
                user = FirebaseAuth.instance.currentUser;
                if (mounted) { Navigator.pop(ctx); setState(() {}); _showToast('Success', 'Name updated', ToastificationType.success); }
              } catch (e) { _showToast('Error', '$e', ToastificationType.error); }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final current = TextEditingController(), newPass = TextEditingController(), confirm = TextEditingController();
    bool loading = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => _buildDialog(
          title: 'Change Password',
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: current, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Current password')),
            const SizedBox(height: 16),
            TextField(controller: newPass, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('New password')),
            const SizedBox(height: 16),
            TextField(controller: confirm, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Confirm new password')),
          ])),
          actions: [
            TextButton(onPressed: loading ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
            TextButton(
              onPressed: loading ? null : () async {
                if (current.text.isEmpty) { _showToast('Error', 'Enter current password', ToastificationType.warning); return; }
                if (newPass.text.length < 6) { _showToast('Error', 'Password must be 6+ characters', ToastificationType.warning); return; }
                if (newPass.text != confirm.text) { _showToast('Error', 'Passwords do not match', ToastificationType.warning); return; }
                setDialogState(() => loading = true);
                try {
                  await user!.reauthenticateWithCredential(EmailAuthProvider.credential(email: user!.email!, password: current.text));
                  await user!.updatePassword(newPass.text);
                  if (mounted) { Navigator.pop(ctx); _showToast('Success', 'Password updated', ToastificationType.success); }
                } catch (e) { setDialogState(() => loading = false); _showToast('Error', '$e', ToastificationType.error); }
              },
              child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog() => showDialog(
    context: context,
    builder: (ctx) => _buildDialog(
      title: 'Sign Out',
      content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
        TextButton(onPressed: () { Navigator.pop(ctx); signOut(); }, child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      ],
    ),
  );

  void _showDeleteAccountDialog() {
    final passController = TextEditingController();
    bool deleting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => _buildDialog(
          title: 'Delete Account', titleColor: Colors.red,
          content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('This action cannot be undone. All your data will be permanently deleted.', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            const Text('Enter your password to confirm:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(controller: passController, obscureText: true, style: const TextStyle(color: Colors.white), decoration: _inputDecoration('Password', borderColor: Colors.red)),
          ]),
          actions: [
            TextButton(onPressed: deleting ? null : () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
            TextButton(
              onPressed: deleting ? null : () async {
                if (passController.text.isEmpty) { _showToast('Error', 'Enter your password', ToastificationType.warning); return; }
                setDialogState(() => deleting = true);
                try {
                  await user!.reauthenticateWithCredential(EmailAuthProvider.credential(email: user!.email!, password: passController.text));
                  final items = await FirebaseFirestore.instance.collection('items').where('userId', isEqualTo: user?.uid).get();
                  for (var doc in items.docs) { await doc.reference.delete(); }
                  await user?.delete();
                  if (mounted) { Navigator.pop(ctx); _showToast('Deleted', 'Account deleted', ToastificationType.success); await Future.delayed(const Duration(milliseconds: 500)); if (mounted) _navigateToLogin(); }
                } catch (e) { setDialogState(() => deleting = false); _showToast('Error', '$e', ToastificationType.error); }
              },
              child: deleting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)) : const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() => showDialog(
    context: context,
    builder: (ctx) => _buildDialog(
      title: 'Help & Support',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildHelpItem(Icons.email_outlined, 'Email', 'support@lostandfound.app'),
        const SizedBox(height: 16),
        _buildHelpItem(Icons.phone_outlined, 'Phone', '+1 234 567 890'),
        const SizedBox(height: 16),
        _buildHelpItem(Icons.access_time, 'Hours', 'Mon-Fri, 9AM-5PM'),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: Colors.white)))],
    ),
  );

  Widget _buildHelpItem(IconData icon, String title, String value) => Row(children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.grey[400], size: 20)),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
    ]),
  ]);
}
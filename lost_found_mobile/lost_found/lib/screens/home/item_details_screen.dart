import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'update_item.dart';

class ItemDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot item;
  const ItemDetailsScreen({super.key, required this.item});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<bool> _verifyPassword(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  if (user == null || user.email == null) return false;

  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Password'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: passwordController.text.trim(),
                  );

                  await user.reauthenticateWithCredential(credential);
                  Navigator.pop(context, true);
                } catch (_) {
                  toastification.show(
                    context: context,
                    type: ToastificationType.error,
                    style: ToastificationStyle.flat,
                    title: const Text('Authentication Failed'),
                    description: const Text('Incorrect password'),
                    alignment: Alignment.topRight,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                  Navigator.pop(context, false);
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ) ??
      false;
}


  /// Owner info modal before edit to enter phone + NIC (for storing)
  Future<Map<String, String>?> _enterOwnerInfo(BuildContext context) async {
    final TextEditingController phoneController =
        TextEditingController(text: item['phone'] ?? '');
    final TextEditingController nicController = TextEditingController();

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Owner Info',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your phone number and NIC. This info will be stored for future inquiries.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nicController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: 'NIC Number',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  if (phoneController.text.trim().isEmpty ||
                      nicController.text.trim().isEmpty) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description: const Text(
                          'Please enter both phone number and NIC'),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  if (phoneController.text.trim().length > 10) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description: const Text('Phone number must be max 10 digits'),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  if (nicController.text.trim().length > 12) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description: const Text('NIC must be max 12 digits'),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  Navigator.pop(context, {
                    'phone': phoneController.text.trim(),
                    'nic': nicController.text.trim(),
                  });
                },
                child: const Text('Continue'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Finder info modal for marking item as found
  Future<Map<String, String>?> _enterFinderInfo(BuildContext context) async {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController nicController = TextEditingController();

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Finder Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the finder\'s phone number and NIC to mark this item as found.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: 'Finder\'s Phone Number',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nicController,
              keyboardType: TextInputType.number,
              maxLength: 12,
              decoration: InputDecoration(
                labelText: 'Finder\'s NIC Number',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final phone = phoneController.text.trim();
                  final nic = nicController.text.trim();
                  
                  if (phone.isEmpty || nic.isEmpty) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description: const Text(
                          'Please enter both phone number and NIC'),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  if (phone.length > 10) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description: const Text('Phone number must be max 10 digits'),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  if (nic.length > 12) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description: const Text('NIC must be max 12 digits'),
                      alignment: Alignment.topRight,
                      autoCloseDuration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  
                  Navigator.pop(context, {
                    'phone': phone,
                    'nic': nic,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Mark as Found'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Mark item as found and save finder info
  Future<void> _markAsFound(BuildContext context) async {
    final finderInfo = await _enterFinderInfo(context);
    
    if (finderInfo == null) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (context.mounted) {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: const Text('Error'),
            description: const Text('User not authenticated'),
            alignment: Alignment.topRight,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
        return;
      }

      final data = item.data() as Map<String, dynamic>;
      
      // Update item status to found first
      await item.reference.update({'status': 'found'});

      // Then save to 'finders' collection
      await FirebaseFirestore.instance.collection('finders').add({
        'userId': currentUser.uid,
        'itemId': item.id,
        'itemName': data['name'] ?? 'Unknown Item',
        'itemType': data['type'] ?? '',
        'finderPhone': finderInfo['phone'],
        'finderNic': finderInfo['nic'],
        'markedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: const Text('Success'),
          description: const Text('Item marked as found!'),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 3),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: const Text('Error'),
          description: Text('Failed: ${e.toString()}'),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = item.data() as Map<String, dynamic>;
    final imageUrl = data['imageUrl'] ?? '';
    final name = data['name'] ?? 'Unknown Item';
    final description = data['description'] ?? '';
    final phone = data['phone'] ?? '';
    final type = data['type'] ?? '';
    final timestamp = data['timestamp'] as Timestamp?;
    final status = data['status'] ?? '';
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner =
        currentUser != null && data['userId'] == currentUser.uid;
    final isFound = status == 'found';

    String formattedDate = 'Unknown date';
    if (timestamp != null) {
      final date = timestamp.toDate();
      formattedDate = '${date.day}/${date.month}/${date.year}';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: isFound
                ? [
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'FOUND',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey[100],
                        child: const Icon(
                          Icons.broken_image_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TYPE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: type == 'Lost'
                          ? Colors.grey[900]
                          : Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (description.isNotEmpty) ...[
                    Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (phone.isNotEmpty) ...[
                    Text(
                      'CONTACT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.phone),
                          const SizedBox(width: 12),
                          Text(phone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(phone),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Now'),
                      ),
                    ),
                  ],
                  if (isOwner && !isFound) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsFound(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Found'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child:OutlinedButton.icon(
  onPressed: () async {
    final verified = await _verifyPassword(context);
    if (!verified) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateItemScreen(item: item),
      ),
    );
  },
  icon: const Icon(Icons.edit),
  label: const Text('Edit Details'),
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.black,
    side: const BorderSide(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
),

                    ),],
                  if (isOwner && isFound) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This item has been marked as found',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
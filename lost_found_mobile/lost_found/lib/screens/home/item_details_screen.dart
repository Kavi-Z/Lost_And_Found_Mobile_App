import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';
import 'update_item.dart';

class ItemDetailsScreen extends StatefulWidget {
  final QueryDocumentSnapshot item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  bool isOwnerTicked = false;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  /// Password confirmation for edit
  Future<bool> _reauthenticateUser(BuildContext context, String email) async {
    final TextEditingController passwordController = TextEditingController();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Password'),
            content: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    final credential = EmailAuthProvider.credential(
                      email: email,
                      password: passwordController.text.trim(),
                    );
                    await user.reauthenticateWithCredential(credential);
                    Navigator.pop(context, true);
                  } catch (_) {
                    Navigator.pop(context, false);
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      alignment: Alignment.topRight,
                      title: const Text('Authentication Failed'),
                      description: const Text('Incorrect password'),
                    );
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Owner verification modal for phone + NIC
  Future<void> _ownerVerification() async {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController nicController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
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
              'Owner Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter your phone number and NIC to confirm ownership.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nicController,
              decoration: InputDecoration(
                labelText: 'NIC Number',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  if (phoneController.text.isEmpty || nicController.text.isEmpty) {
                    toastification.show(
                      context: context,
                      type: ToastificationType.error,
                      style: ToastificationStyle.flat,
                      title: const Text('Error'),
                      description:
                          const Text('Please enter both phone number and NIC'),
                      alignment: Alignment.topRight,
                    );
                    return;
                  }

                  // Store phone + NIC and mark item as "founded" in DB
                  await FirebaseFirestore.instance
                      .collection(widget.item.reference.parent.id)
                      .doc(widget.item.id)
                      .update({
                    'ownerPhone': phoneController.text.trim(),
                    'ownerNIC': nicController.text.trim(),
                    'founded': true,
                  });

                  toastification.show(
                    context: context,
                    type: ToastificationType.success,
                    style: ToastificationStyle.flat,
                    title: const Text('Verified'),
                    description: const Text('Item marked as founded'),
                    alignment: Alignment.topRight,
                    autoCloseDuration: const Duration(seconds: 3),
                  );

                  setState(() => isOwnerTicked = true);
                  Navigator.pop(context, true);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() => isOwnerTicked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.item['imageUrl'] ?? '';
    final name = widget.item['name'] ?? 'Unknown Item';
    final description = widget.item['description'] ?? '';
    final phone = widget.item['phone'] ?? '';
    final type = widget.item['type'] ?? '';
    final timestamp = widget.item['timestamp'] as Timestamp?;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner =
        currentUser != null && widget.item['userId'] == currentUser.uid;

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
                      color: isOwnerTicked
                          ? Colors.green
                          : (type == 'Lost' ? Colors.grey[900] : Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOwnerTicked ? 'FOUNDED' : type.toUpperCase(),
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
                  if (isOwner) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isOwnerTicked,
                          onChanged: (val) async {
                            if (val == true) {
                              await _ownerVerification();
                            }
                          },
                        ),
                        const Text(
                          'I am the owner of this item',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final success = await _reauthenticateUser(
                              context, currentUser!.email!);
                          if (success) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UpdateItemScreen(item: widget.item),
                              ),
                            );
                          }
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

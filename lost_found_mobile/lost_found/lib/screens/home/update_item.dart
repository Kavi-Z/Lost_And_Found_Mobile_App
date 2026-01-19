import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toastification/toastification.dart';

class UpdateItemScreen extends StatefulWidget {
  final QueryDocumentSnapshot item;
  const UpdateItemScreen({super.key, required this.item});

  @override
  State<UpdateItemScreen> createState() => _UpdateItemScreenState();
}

class _UpdateItemScreenState extends State<UpdateItemScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item['name']);
    descriptionController =
        TextEditingController(text: widget.item['description']);
    phoneController = TextEditingController(text: widget.item['phone']);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }

  Future<bool> _confirmPassword() async {
  final TextEditingController passwordController = TextEditingController();

  return await showModalBottomSheet<bool>(
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
                'Confirm Password',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For security reasons, please confirm your password.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: _inputDecoration('Password'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final user = FirebaseAuth.instance.currentUser!;
                      final credential = EmailAuthProvider.credential(
                        email: user.email!,
                        password: passwordController.text.trim(),
                      );
                      await user.reauthenticateWithCredential(credential);

                      // Success toast with AWAIT before popping
                      if (mounted) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.success,
                          style: ToastificationStyle.flat,
                          alignment: Alignment.topRight,
                          autoCloseDuration: const Duration(seconds: 3),
                          title: const Text('Authenticated'),
                          description: const Text('Password confirmed successfully'),
                        );

                        await Future.delayed(const Duration(milliseconds: 800));
                        
                        if (mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    } catch (_) {
                      // Error toast with AWAIT before popping
                      if (mounted) {
                        toastification.show(
                          context: context,
                          type: ToastificationType.error,
                          style: ToastificationStyle.flat,
                          alignment: Alignment.topRight,
                          autoCloseDuration: const Duration(seconds: 3),
                          title: const Text('Authentication Failed'),
                          description: const Text('Incorrect password'),
                        );

                        await Future.delayed(const Duration(milliseconds: 800));
                        
                        if (mounted) {
                          Navigator.pop(context, false);
                        }
                      }
                    }
                  },
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ) ??
      false;
}

  Future<void> _updateItem() async {
    final confirmed = await _confirmPassword();
    if (!confirmed) return;

    await FirebaseFirestore.instance
        .collection(widget.item.reference.parent.id)
        .doc(widget.item.id)
        .update({
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    // Success toast for update
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: const Text("Success"),
          description: const Text("Item added successfully!"),
          alignment: Alignment.topRight,
          autoCloseDuration: const Duration(seconds: 3),
          primaryColor: Colors.green,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          borderRadius: BorderRadius.circular(12),
          showProgressBar: true,
          closeButtonShowType: CloseButtonShowType.onHover,
        );

    Navigator.pop(context);
  }

  Future<void> _deleteItem() async {
    final confirmed = await _confirmPassword();
    if (!confirmed) return;

    await widget.item.reference.delete();

    // Success toast for delete
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 3),
      title: const Text('Deleted'),
      description: const Text('Item deleted successfully'),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Details',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Modify or remove your item listing',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration('Item Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: _inputDecoration('Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: _inputDecoration('Phone Number'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _updateItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: _deleteItem,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Delete Item',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

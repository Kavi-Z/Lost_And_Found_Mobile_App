import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddItemScreen extends StatefulWidget {
  final String type;
  const AddItemScreen({super.key, required this.type});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();

  Uint8List? imageBytes;
  bool loading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      imageBytes = await file.readAsBytes();
      setState(() {});
    }
  }

  Future<String> uploadImage() async {
    try {
      // Use separate folders for Lost and Found items
      final folder = widget.type == 'Lost' ? 'lost_items' : 'found_items';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('$folder/$fileName');

      print('Uploading to: $folder/$fileName');
      await ref.putData(imageBytes!);
      final downloadURL = await ref.getDownloadURL();
      print('Upload successful: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> submitItem() async {
    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.email ?? "No user"}');
    
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
      }
      return;
    }

    if (nameController.text.isEmpty || imageBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    setState(() => loading = true);

    try {
      // Step 1: Upload image
      print('Uploading image...');
      final imageUrl = await uploadImage();
      print('Image uploaded: $imageUrl');

      // Step 2: Save to Firestore
      print('Saving to Firestore...');
      final docRef = await FirebaseFirestore.instance.collection('items').add({
        'name': nameController.text.trim(),
        'description': descController.text.trim(),
        'phone': phoneController.text.trim(),
        'type': widget.type,
        'imageUrl': imageUrl,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Saved to Firestore with ID: ${docRef.id}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add ${widget.type} Item"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: imageBytes == null
                    ? const Center(child: Text("Tap to select image"))
                    : Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submitItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

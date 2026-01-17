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
    final ref = FirebaseStorage.instance
        .ref('items/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putData(imageBytes!);
    return await ref.getDownloadURL();
  }

  Future<void> submitItem() async {
    if (nameController.text.isEmpty || imageBytes == null) return;

    setState(() => loading = true);

    final imageUrl = await uploadImage();

    await FirebaseFirestore.instance.collection('items').add({
      'name': nameController.text.trim(),
      'description': descController.text.trim(),
      'phone': phoneController.text.trim(),
      'type': widget.type,
      'imageUrl': imageUrl,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
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

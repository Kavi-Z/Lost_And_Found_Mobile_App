import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot item;
  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['name']),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['description'] ?? ''),
            const SizedBox(height: 10),
            Text("Phone: ${item['phone'] ?? ''}"),
            const SizedBox(height: 10),
            Text("Type: ${item['type']}"),
          ],
        ),
      ),
    );
  }
}

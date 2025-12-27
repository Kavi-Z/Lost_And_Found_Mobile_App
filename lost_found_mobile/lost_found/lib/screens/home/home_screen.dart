import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController itemNameController = TextEditingController();
  String itemType = "Lost";  

  Future<void> addItem() async {
    final itemName = itemNameController.text.trim();
    if (itemName.isEmpty) return;

    await FirebaseFirestore.instance.collection('items').add({
      'name': itemName,
      'type': itemType,
      'timestamp': FieldValue.serverTimestamp(),
    });

    itemNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lost & Found",style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: itemNameController,
                  decoration: const InputDecoration(
                    labelText: "Item Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Lost"),
                      selected: itemType == "Lost",
                      onSelected: (_) => setState(() => itemType = "Lost"),
                    ),
                    const SizedBox(width: 10),
                    ChoiceChip(
                      label: const Text("Found"),
                      selected: itemType == "Found",
                      onSelected: (_) => setState(() => itemType = "Found"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text("Add Item",style: TextStyle(color: Colors.white)),

                ),
              ],
            ),
          ),

          const Divider(),

          // Lost Items List
          const Text(
            "Lost Items",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('type', isEqualTo: 'Lost')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index]['name']),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Found Items List
          const Text(
            "Found Items",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('items')
                  .where('type', isEqualTo: 'Found')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(items[index]['name']),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
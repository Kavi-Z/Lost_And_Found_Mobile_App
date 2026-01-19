import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Items',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, i) => _ItemTile(item: snapshot.data!.docs[i]),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No items posted yet', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final DocumentSnapshot item;
  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final data = item.data() as Map<String, dynamic>;
    final isResolved = data['isResolved'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _ItemImage(url: data['imageUrl']),
          const SizedBox(width: 16),
          Expanded(child: _ItemInfo(data: data, isResolved: isResolved)),
          _ItemMenu(item: item, isResolved: isResolved),
        ],
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  final String? url;
  const _ItemImage({this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: url != null && url!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(url!, fit: BoxFit.cover),
            )
          : Icon(Icons.image, color: Colors.grey[400]),
    );
  }
}

class _ItemInfo extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isResolved;
  const _ItemInfo({required this.data, required this.isResolved});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            _Badge(text: data['type'] ?? '', isLost: data['type'] == 'Lost'),
            if (isResolved) ...[
              const SizedBox(width: 8),
              _Badge(text: 'Resolved', isResolved: true),
            ],
          ],
        ),
      ],
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final DocumentSnapshot item;
  final bool isResolved;
  const _ItemMenu({required this.item, required this.isResolved});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'toggle',
          child: Text(isResolved ? 'Mark Unresolved' : 'Mark Resolved'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _handleAction(BuildContext context, String action) {
    if (action == 'toggle') {
      FirebaseFirestore.instance
          .collection('items')
          .doc(item.id)
          .update({'isResolved': !isResolved});
    } else if (action == 'delete') {
      _showDeleteDialog(context);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('items').doc(item.id).delete();
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final bool isLost;
  final bool isResolved;

  const _Badge({required this.text, this.isLost = false, this.isResolved = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = isResolved ? Colors.blue[50]! : (isLost ? Colors.red[50]! : Colors.green[50]!);
    final textColor = isResolved ? Colors.blue[700]! : (isLost ? Colors.red[700]! : Colors.green[700]!);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}
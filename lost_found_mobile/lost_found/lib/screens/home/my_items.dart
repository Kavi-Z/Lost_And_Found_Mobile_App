import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'item_details_screen.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser!;
  late TabController _tabController;

  List<QueryDocumentSnapshot> _lostItemsCache = [];
  List<QueryDocumentSnapshot> _foundItemsCache = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Items'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Lost'),
            Tab(text: 'Found'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _itemsList(type: 'Lost'),
          _itemsList(type: 'Found'),
        ],
      ),
    );
  }

  Widget _itemsList({required String type}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: type)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<QueryDocumentSnapshot> itemsToDisplay;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          itemsToDisplay = snapshot.data!.docs;
          
          if (type == 'Lost') {
            _lostItemsCache = itemsToDisplay;
          } else {
            _foundItemsCache = itemsToDisplay;
          }
        } else {
          itemsToDisplay = type == 'Lost' ? _lostItemsCache : _foundItemsCache;
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            itemsToDisplay.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (itemsToDisplay.isEmpty) {
          return const Center(
            child: Text(
              'No items found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itemsToDisplay.length,
          itemBuilder: (context, index) {
            final doc = itemsToDisplay[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isFound = data['status'] == 'found';

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailsScreen(item: doc),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isFound ? Colors.green.shade900 : Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(16),
                  border: isFound
                      ? Border.all(color: Colors.green, width: 1.5)
                      : Border.all(color: Colors.grey.shade800),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: data['imageUrl'] ?? '',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey.shade800),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, color: Colors.white),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] ?? 'Unknown Item',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              data['location'] ?? '',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            if (isFound) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'FOUND',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
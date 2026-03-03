// lib/pages/staff/staff_inventory_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_drawer.dart';

class StaffInventoryPage extends StatelessWidget {
  const StaffInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final staffId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('H O M E'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Cars")
            .where("TentId", isEqualTo: staffId) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final cars = snapshot.data?.docs ?? [];

          if (cars.isEmpty) {
            return const Center(child: Text("No cars listed yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              var carData = cars[index].data() as Map<String, dynamic>;
              return _buildStaffCarTile(context, carData, cars[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildStaffCarTile(BuildContext context, Map<String, dynamic> data, String carId) {
    String status = data['Status'] ?? 'available';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Car Image Thumbnail
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions_car),
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data['Brand']} ${data['Model']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text("฿ ${data['Price']}", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 5),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Edit Button
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () {
              
            },
          ),
        ],
      ),
    );
  }
 

  Color _getStatusColor(String status) {
    switch (status) {
      case 'sold': return Colors.red;
      case 'reserved': return Colors.orange;
      default: return Colors.green;
    }
  }
}
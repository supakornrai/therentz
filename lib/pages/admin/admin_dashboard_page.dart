import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedRole = "All"; 

  @override
  Widget build(BuildContext context) {
    final String currentAdminId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('H O M E'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search ",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Role: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedRole,
                      dropdownColor: Theme.of(context).colorScheme.secondary,
                      items: ["All", "user", "staff"].map((role) {
                        return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedRole = val!),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("Users").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text("Error loading data"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String username = (data['Username'] ?? "").toString().toLowerCase();
                  String email = (data['Email'] ?? "").toString().toLowerCase();
                  String role = data['Role'] ?? "user";

                  bool matchesSearch = username.contains(_searchQuery) || email.contains(_searchQuery);
                  bool matchesRole = _selectedRole == "All" || role == _selectedRole;
                  bool isNotMe = doc.id != currentAdminId;

                  return matchesSearch && matchesRole && isNotMe;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index].data() as Map<String, dynamic>;
                    return _buildUserDisplayTile(context, userData, users[index].id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDisplayTile(BuildContext context, Map<String, dynamic> data, String uid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['Username'] ?? 'User',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text("ID : ${uid.substring(0, 8)}...", style: _subStyle(context)),
              Text("Email : ${data['Email']}", style: _subStyle(context)),
              const SizedBox(height: 8),
              // Show Role badge
              _buildRoleBadge(data['Role'] ?? "user"),
            ],
          ),
          // implement the profile image
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.person,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: role == "staff" ? Colors.orange.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: role == "staff" ? Colors.orange : Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TextStyle _subStyle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.inversePrimary,
    fontSize: 14,
  );
}
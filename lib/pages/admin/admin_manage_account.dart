import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_drawer.dart';

class AdminManageAccounts extends StatefulWidget {
  const AdminManageAccounts({super.key});

  @override
  State<AdminManageAccounts> createState() => _AdminManageAccountsState();
}

class _AdminManageAccountsState extends State<AdminManageAccounts> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedRole = "All";
  @override
  Widget build(BuildContext context) {
    final String currentAdminId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('M A N A G E'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: MyDrawer(),
      body: Column(
        children: [
         Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search by username or email...",
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
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedRole = value!),
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
                if (snapshot.hasError) return const Center(child: Text("Error"));
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

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index].data() as Map<String, dynamic>;
                    return _buildUserTile(context, userData, users[index].id);
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

  Widget _buildUserTile(
    BuildContext context,
    Map<String, dynamic> data,
    String uid,
  ) {
    bool isOnline = true; // status logic -> suspend, online, offline

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
                data['Username'] ?? 'New User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "ID : ${uid.substring(0, 8)}...",
                style: _subTextStyle(context),
              ),
              Text("Email : ${data['Email']}", style: _subTextStyle(context)),
              Row(
                children: [
                  Text("Status : ", style: _subTextStyle(context)),
                  // implement the user status method -> suspened, online, offline
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: TextStyle(
                      color: isOnline ? Colors.blue : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Manage Button
              ElevatedButton(
                onPressed: () => _showManageOptions(context, uid, data),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Manage",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Profile Image
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: Icon(
              Icons.person_pin,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _subTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
      fontSize: 14,
    );
  }

  void _showManageOptions(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.orange,
              ),
              title: const Text("Set as Staff"),
              onTap: () => _updateRole(context, uid, "staff"),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Set as User"),
              onTap: () => _updateRole(context, uid, "user"),
            ),
            ListTile(
              leading: Icon(
                data['isSuspended'] == true ? Icons.check_circle : Icons.block,
                color: data['isSuspended'] == true ? Colors.green : Colors.red,
              ),
              title: Text(
                data['isSuspended'] == true
                    ? "Restore Account"
                    : "Suspend Account",
              ),
              onTap: () =>
                  _toggleSuspension(context, uid, data['isSuspended'] ?? false),
            ),
          ],
        ),
      ),
    );
  }

  void _updateRole(BuildContext context, String uid, String role) {
    FirebaseFirestore.instance.collection("Users").doc(uid).update({
      'Role': role,
    });
    Navigator.pop(context);
  }

  void _toggleSuspension(
    BuildContext context,
    String uid,
    bool currentStatus,
  ) async {
    await FirebaseFirestore.instance.collection("Users").doc(uid).update({
      'isSuspended': !currentStatus,
    });

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus ? "Account Restored" : "Account Suspended",
          ),
        ),
      );
    }
  }


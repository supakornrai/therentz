import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminManageAccounts extends StatefulWidget {
  AdminManageAccounts({super.key});

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
        title: Text('Manage Accounts'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                  decoration: InputDecoration(
                    hintText: "Search name or email...",
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.secondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      "Filter by Role: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        underline: SizedBox(),
                        dropdownColor: Theme.of(context).colorScheme.secondary,
                        items: ["All", "user", "staff"].map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role.toUpperCase(),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
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
                if (snapshot.hasError) return Center(child: Text("Error"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
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
                  return Center(child: Text("No users found"));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  String role = data['Role'] ?? 'user';
  bool isSuspended = data['isSuspended'] ?? false;

  return Container(
    margin: EdgeInsets.only(bottom: 20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['Username'] ?? 'New User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    data['Email'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (role == 'staff' ? Colors.orange : Colors.blue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: (role == 'staff' ? Colors.orange : Colors.blue).withOpacity(0.3)),
              ),
              child: Text(
                role.toUpperCase(),
                style: TextStyle(
                  color: role == 'staff' ? Colors.orange : Colors.blue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showManageOptions(context, uid, data),
                icon: Icon(Icons.settings_suggest_rounded, size: 18),
                label: Text("Manage Account"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (isSuspended) ...[
              SizedBox(width: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Icon(Icons.person_off_rounded, color: Colors.red, size: 20),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

TextStyle _subTextStyle(BuildContext context) {
  return TextStyle(
    color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
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
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.admin_panel_settings, color: Colors.orange),
            title: Text("Set as Staff"),
            onTap: () => _updateRole(context, uid, "staff"),
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.green),
            title: Text("Set as User"),
            onTap: () => _updateRole(context, uid, "user"),
          ),
          ListTile(
            leading: Icon(
              data['isSuspended'] == true ? Icons.check_circle : Icons.no_accounts_rounded,
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
          if (data['Role'] == 'staff')
            ListTile(
              leading: Icon(Icons.directions_car, color: Theme.of(context).colorScheme.primary),
              title: Text("Assign Car"),
              onTap: () => _showAssignCarDialog(context, uid, data['assignedCarId']),
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
        content: Text(currentStatus ? "Account Restored" : "Account Suspended"),
      ),
    );
  }
}

void _showAssignCarDialog(
  BuildContext context,
  String uid,
  String? currentCarId,
) {
  showDialog(
    context: context,
    builder: (context) {
      String? selectedCarId = currentCarId;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Assign Car to Staff"),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("Cars").snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("No cars available.");
                  }

                  final cars = snapshot.data!.docs;

                  // Make sure currentCarId exists in the list to avoid dropdown assertion error
                  bool carExists = selectedCarId == null || cars.any((car) => car.id == selectedCarId);
                  if (!carExists) selectedCarId = null;

                  return DropdownButton<String>(
                    isExpanded: true,
                    value: selectedCarId,
                    hint: Text("Select a car"),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text("None (Remove assignment)"),
                      ),
                      ...cars.map((car) {
                        final carData = car.data() as Map<String, dynamic>;
                        final String brand = carData['Brand'] ?? 'Unknown';
                        final String model = carData['Model'] ?? 'Unknown';
                        return DropdownMenuItem<String>(
                          value: car.id,
                          child: Text("$brand $model"),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCarId = value;
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection("Users").doc(uid).update({
                    'assignedCarId': selectedCarId,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Car assigned successfully")),
                    );
                  }
                },
                child: Text("Save"),
              ),
            ],
          );
        },
      );
    },
  );
}

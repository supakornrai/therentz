import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/components/my_drawer.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('H O M E'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: MyDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Reports")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error loading reports"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return const Center(child: Text("No reports found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var reportData = reports[index].data() as Map<String, dynamic>;
              return _buildReportTile(context, reportData, reports[index].id);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, Map<String, dynamic> report, String reportId) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("PENDING REPORT", 
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
            Text(_formatTimestamp(report['timestamp']), style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 15),

        _buildUserLookupRow(context, "Target User", report['ownerId']),
        const SizedBox(height: 8),
        
        _buildUserLookupRow(context, "Reported By", report['reportedBy']),

        const SizedBox(height: 20),

        Row(
          children: [
            const SizedBox(width: 10),
            IconButton(
              onPressed: () => _deleteReport(reportId),
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ],
        )
      ],
    ),
  );
}

Widget _buildUserLookupRow(BuildContext context, String label, String uid) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection("Users").doc(uid).get(),
    builder: (context, snapshot) {
      String displayName = "Loading...";
      if (snapshot.hasData && snapshot.data!.exists) {
        displayName = snapshot.data!['Username'] ?? "Unknown";
      }
      return RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: displayName),
          ],
        ),
      );
    },
  );
}


  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month} ${date.hour}:${date.minute}";
  }

  void _deleteReport(String id) {
    FirebaseFirestore.instance.collection("Reports").doc(id).delete();
  }
}
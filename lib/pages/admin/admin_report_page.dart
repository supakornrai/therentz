import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminReportsPage extends StatelessWidget {
  AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Admin Reports'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Reports")
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error loading reports"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!.docs;

          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  SizedBox(height: 16),
                  Text("No reports to review.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _buildReportTile(
    BuildContext context,
    Map<String, dynamic> report,
    String reportId,
  ) {
    String type = report['type'] ?? '';
    bool isEvaluation = type == 'showroom_evaluation' || type == 'staff_evaluation';

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isEvaluation ? Colors.green : Colors.redAccent).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  type == 'showroom_evaluation'
                      ? "TENT EVALUATION"
                      : type == 'staff_evaluation'
                          ? "STAFF EVALUATION"
                          : "SECURITY REPORT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isEvaluation ? Colors.green : Colors.redAccent,
                  ),
                ),
              ),
              Text(
                _formatTimestamp(report['timestamp']),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isEvaluation) ...[
            if (type == 'staff_evaluation') ...[
              _buildUserLookupRow(context, "Target Staff", report['targetStaffId']),
              SizedBox(height: 8),
            ],
            Row(
              children: [
                Text("Rating: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ...List.generate(5, (index) => Icon(
                  index < (report['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 18,
                  color: Colors.orange,
                )),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                report['message'] ?? 'No feedback provided.',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.8),
                ),
              ),
            ),
          ] else ...[
            _buildUserLookupRow(context, "Target User", report['ownerId']),
            SizedBox(height: 8),
          ],
          SizedBox(height: 12),
          _buildUserLookupRow(context, "Reported By", report['reportedBy']),

          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => _deleteReport(reportId),
              icon: Icon(Icons.delete_sweep_rounded, color: Colors.redAccent.withOpacity(0.5)),
            ),
          ),
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            children: [
              TextSpan(
                text: "$label: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
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

  TextStyle _subTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.inversePrimary,
      fontSize: 14,
    );
  }

  void _deleteReport(String id) {
    FirebaseFirestore.instance.collection("Reports").doc(id).delete();
  }
}

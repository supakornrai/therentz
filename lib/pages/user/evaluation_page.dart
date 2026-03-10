import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/services/chat/chat_service.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  int _tentRating = 5;
  final TextEditingController _tentCommentController = TextEditingController();

  int _staffRating = 5;
  final TextEditingController _staffCommentController = TextEditingController();
  String? _selectedStaffId;
  String? _selectedStaffEmail;

  void _submitTentEvaluation() async {
    if (_tentCommentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a comment")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("Reports").add({
      'type': 'showroom_evaluation',
      'rating': _tentRating,
      'message': _tentCommentController.text,
      'reportedBy': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      _tentCommentController.clear();
      setState(() => _tentRating = 5);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Showroom evaluation submitted!")),
      );
    }
  }

  void _submitStaffEvaluation() async {
    if (_selectedStaffId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a staff member")),
      );
      return;
    }

    if (_staffCommentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a comment")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("Reports").add({
      'type': 'staff_evaluation',
      'targetStaffId': _selectedStaffId,
      'rating': _staffRating,
      'message': _staffCommentController.text,
      'reportedBy': currentUserId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      _staffCommentController.clear();
      setState(() {
        _staffRating = 5;
        _selectedStaffId = null;
        _selectedStaffEmail = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Staff evaluation submitted!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Evaluation"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // SHOWROOM SECTION
            _buildEvaluationCard(
              context,
              title: "Evaluate Showroom",
              subtitle: "Rate your overall tent experience",
              onRatingChanged: (val) => setState(() => _tentRating = val),
              rating: _tentRating,
              controller: _tentCommentController,
              hint: "How was your experience at our showroom?",
              onSubmit: _submitTentEvaluation,
            ),

            const SizedBox(height: 24),

            // STAFF SECTION
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Evaluate Staff",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text("Rate individual service", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _chatService.getChattedUsersStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final chats = snapshot.data ?? [];
                      final staffList = chats.where((u) => u['Role'] == 'staff').toList();

                      if (staffList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "You haven't interacted with any staff yet.",
                              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5)),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              value: _selectedStaffId,
                              hint: const Text("Select Staff Member"),
                              items: staffList.map((staff) {
                                return DropdownMenuItem<String>(
                                  value: staff['Id'],
                                  child: Text(staff['Email'] ?? "Unknown Staff"),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedStaffId = val;
                                  _selectedStaffEmail = staffList.firstWhere((s) => s['Id'] == val)['Email'];
                                });
                              },
                            ),
                          ),
                          if (_selectedStaffId != null) ...[
                            const SizedBox(height: 20),
                            _buildRatingStars(_staffRating, (val) => setState(() => _staffRating = val)),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _staffCommentController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "Feedback for $_selectedStaffEmail",
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.all(16),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildSubmitButton(_submitStaffEvaluation),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int rating,
    required Function(int) onRatingChanged,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onSubmit,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildRatingStars(rating, onRatingChanged),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 20),
          _buildSubmitButton(onSubmit),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text("Submit Evaluation", style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRatingStars(int rating, Function(int) onRatingChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
          onPressed: () => onRatingChanged(index + 1),
        );
      }),
    );
  }
}

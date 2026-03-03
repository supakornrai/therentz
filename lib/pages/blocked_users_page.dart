import 'package:flutter/material.dart';
import 'package:the_rentz/components/user_tile.dart';
import 'package:the_rentz/services/auth/auth_service.dart';
import 'package:the_rentz/services/chat/chat_service.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  final AuthService authService = AuthService();
  final ChatService chatService = ChatService();

  void _showUnblockBox(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Unblock User"),
        content: const Text("Are you sure you want to unblock this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              chatService.unBlockUser(userId); 
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User Unblocked")),
              );
            },
            child: const Text("Unblock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String userID = authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getblockedUserStream(userID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading blocked users.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final blockedUsers = snapshot.data ?? [];

          if (blockedUsers.isEmpty) {
            return const Center(child: Text("No blocked users."));
          }

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user['Email'] ?? 'Unknown',
                onTap: () => _showUnblockBox(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}
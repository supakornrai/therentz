import 'package:flutter/material.dart';
import 'package:the_rentz/components/user_tile.dart';
import 'package:the_rentz/pages/chat_page.dart';
import 'package:the_rentz/services/auth/auth_service.dart';
import 'package:the_rentz/services/chat/chat_service.dart';

class InboxPage extends StatelessWidget {
  InboxPage({super.key});

  //chat && auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  void logout() {
    //get auth service
    _authService.signOut();
  }

  void _showOptions(BuildContext context, String userId, String email) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // Report User
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text('Report User'),
                onTap: () {
                  _chatService.reportUser(userId); 
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User Reported"))
                  );
                },
              ),
              // Block User
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block User'),
                onTap: () {
                  _showBlockConfirmation(context, userId);
                },
              ),
              // Cancel
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showBlockConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Block User"),
        content: const Text("Are you sure you want to block this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _chatService.blockUser(userId); // Call your service
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User Blocked"))
              );
            },
            child: const Text("Block"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStreamExcludingBlocked(),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }

        //return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  //build individual list title for user
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    //display all user except current user
    if (userData['Email'] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData['Email'],
        onTap: () {
          //tap on user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['Email'],
                receiverID: userData["Id"],
              ),
            ),
          );
        },
        onLongPress: () => _showOptions(context, userData["Id"], userData['Email']),
      );
    } else {
      return Container();
    }
  }
}

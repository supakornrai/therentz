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
                leading: Icon(Icons.flag),
                title: Text('Report User'),
                onTap: () {
                  _chatService.reportUser(userId); 
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("User Reported"))
                  );
                },
              ),
              // Cancel
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Direct Messages'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getChattedUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
               SizedBox(height: 16),
               Text("No messages yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
               SizedBox(height: 8),
                Text("Start a conversation with our staff",
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5))),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.only(top: 10),
          children: users.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    if (userData['Email'] != _authService.getCurrentUser()!.email) {
      return StreamBuilder<int>(
        stream: _chatService.getUnreadCountStream(userData["Id"]),
        builder: (context, unreadSnapshot) {
          int unreadCount = unreadSnapshot.data ?? 0;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: UserTile(
              text: userData['Email'],
              unreadCount: unreadCount,
              onTap: () {
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
            ),
          );
        },
      );
    } else {
      return SizedBox();
    }
  }
}

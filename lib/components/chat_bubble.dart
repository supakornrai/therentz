import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

   ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Theme.of(context).colorScheme.primary 
            : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            offset:  Offset(0, 2),
          ),
        ],
        border: isCurrentUser 
            ? null 
            : Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
      ),
      padding:  EdgeInsets.all(16),
      margin:  EdgeInsets.symmetric(vertical: 4, horizontal: 20),
      child: Text(
        message,
        style: TextStyle(
          color: isCurrentUser 
              ? Colors.white 
              : Theme.of(context).colorScheme.inversePrimary,
          fontSize: 18,
        ),
      ),
    );
  }
}

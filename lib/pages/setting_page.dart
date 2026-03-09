import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_rentz/pages/blocked_users_page.dart';
import 'package:the_rentz/themes/theme_provider.dart';

class SettingPage extends StatelessWidget {
  final bool showBlockUser;
  const SettingPage({super.key, this.showBlockUser = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            //dark mode
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(25),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
        
                  CupertinoSwitch(
                    value: Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).isDarkMode,
                    onChanged: (value) => Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme(),
                  ),
                ],
              ),
            ),
            
                  ],
                ),
              ),
        );
  
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/components/my_settings_tile.dart';
import 'package:twitmania/themes/theme_provider.dart';

import '../helper/navigate_pages.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S E T T I N G S'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // dark mode
          MySettingsTile(
            title: 'Dark Mode',
            action: CupertinoSwitch(
              onChanged: (value) =>
                  Provider.of<ThemeProvider>(context, listen: false)
                      .toggleTheme(),
              value:
                  Provider.of<ThemeProvider>(context, listen: false).isDarkMode,
            ),
          ),
          // block user account
          GestureDetector(
            onTap: () => goToBlockedUsersPage(context),
            child: MySettingsTile(
                title: 'Blocked Users',
                action: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ),
          // account settings
          MySettingsTile(
              title: 'Account Settings',
              action: IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => goAccountSettingsPage(context),
              ))
        ],
      ),
    );
  }
}

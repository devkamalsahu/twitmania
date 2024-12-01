import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitmania/components/my_drawer_tile.dart';
import 'package:twitmania/pages/profile_page.dart';
import 'package:twitmania/pages/search_page.dart';
import 'package:twitmania/pages/settings_page.dart';

import '../services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Icon(
                Icons.person,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              Divider(
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(
                height: 10,
              ),
              MyDrawerTile(
                icon: Icons.home,
                title: 'H O M E',
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              MyDrawerTile(
                icon: Icons.person,
                title: 'P R O F I L E',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          uid: _auth.getCurrentUser()!.uid,
                        ),
                      ));
                },
              ),
              MyDrawerTile(
                icon: Icons.search,
                title: 'S E A R C H',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(),
                    ),
                  );
                },
              ),
              MyDrawerTile(
                icon: Icons.settings,
                title: 'S E T T I N G S',
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingsPage(),
                    ),
                  );
                },
              ),
              const Spacer(),
              MyDrawerTile(
                  icon: Icons.logout,
                  title: 'L O G O U T',
                  onTap: () {
                    _auth.logout();
                  })
            ],
          ),
        ),
      ),
    );
  }
}

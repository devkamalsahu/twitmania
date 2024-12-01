/*
  BLOCKED USERS PAGE

  This page displays a list of users that have been blocked
  - you can unblock users here

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  // providers
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    loadBlockedUsers();
    super.initState();
  }

  Future<void> loadBlockedUsers() async {
    await databaseProvider.loadBlockUsers();
  }

  void _showUnblockConfirmation(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: const Text(
          'Are you sure you want to unblock this user?',
        ),
        actions: [
          // cancel button
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),

          // Unblock button
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await databaseProvider.unblockUser(userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message unblocked!'),
                  ),
                );
              },
              child: const Text('Unblock'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockedUsers = listeningProvider.blockedUsers;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Blocked Users'),
      ),
      body: blockedUsers.isEmpty
          ? const Center(
              child: Text('No blocked users...'),
            )
          : ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                // get each user
                final user = blockedUsers[index];

                return ListTile(
                  title: Text(user.name),
                  subtitle: Text('@${user.username}'),
                  trailing: IconButton(
                    icon: Icon(Icons.block),
                    onPressed: () => _showUnblockConfirmation(user.uid),
                  ),
                );
              },
            ),
    );
  }
}



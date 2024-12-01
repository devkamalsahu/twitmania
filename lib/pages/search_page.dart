/*
    SEARCH PAGE 

    User can search for any user in the databse
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/components/my_user_tile.dart';
import 'package:twitmania/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // provider
    final databasePorvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search Users...',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
            border: InputBorder.none,
          ),
          //   search will begin after each new character has been type
          onChanged: (value) {
            // search users
            if (value.isNotEmpty) {
              databasePorvider.searchUsers(value);
            }
            // clear result
            else {
              databasePorvider.searchUsers('');
            }
          },
        ),
      ),
      body: listeningProvider.searchResults.isEmpty
          ?
          //   no users found.. listeningProvider
          Center(
              child: Text('No users found..'),
            )
          :
          // users found!
          ListView.builder(
              itemCount: listeningProvider.searchResults.length,
              itemBuilder: (context, index) {
                // get each user from search result
                final user = listeningProvider.searchResults[index];

                return MyUserTile(user: user);
              },
            ),
    );
  }
}

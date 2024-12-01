/*
  USER LIST TILE 

  This is to display each user as a nice tile. We will use this when we need to display a list of users
  for example in the user search results or viewing the followers of a user.

  -----------------------------------------------------------------------------------------------------------

  To use this widget, you need;
  
  - a user


*/

import 'package:flutter/material.dart';
import 'package:twitmania/models/user.dart';
import 'package:twitmania/pages/profile_page.dart';

class MyUserTile extends StatelessWidget {
  const MyUserTile({super.key, required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        subtitle: Text('@${user.username}'),
        subtitleTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.primary),
        title: Text(user.name),
        titleTextStyle:
            TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        leading: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
        ),
        // on tap -> go to user profile page
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: user.uid),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:twitmania/models/post.dart';
import 'package:twitmania/pages/home_page.dart';
import 'package:twitmania/pages/profile_page.dart';

import '../pages/account_settings_page.dart';
import '../pages/blocked_users_page.dart';
import '../pages/post_page.dart';

void goUserPage(BuildContext context, String uid) {
  // navigate to the page
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(uid: uid),
    ),
  );
}

// navigate to post page
void goPostPage(BuildContext context, Post post) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PostPage(
        post: post,
      ),
    ),
  );
}

// navigate to blocked users page
void goToBlockedUsersPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => BlockedUsersPage(),
  ));
}

// navigate to account settings page
void goAccountSettingsPage(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => AccountSettingsPage(),
  ));
}

// go to home page ( but remove all previous routes, this is good for reload )
void goHomePage(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => HomePage(),
    ),
    (route) => route.isFirst,
  );
}

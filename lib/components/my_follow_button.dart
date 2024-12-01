/*
  FOLLOW BUTTON

  This is a follow / unfollow button, depending on whose profile page we are
  currently viewing.

  ---------------------------------------------------------------------------------

  To use this widget, you need:
  - a function ( e.g. toggleFollow() when the button is pressed )
  - isFollowing ( e.g. false -> then we will show follow button instead of unfollow button )

*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyFollowButton extends StatelessWidget {
  const MyFollowButton({super.key, this.onPressed, required this.isFollowing});
  final void Function()? onPressed;
  final bool isFollowing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MaterialButton(
          onPressed: onPressed,
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          padding: const EdgeInsets.all(25),
          child: Text(
            isFollowing ? 'Unfollow' : 'Follow',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

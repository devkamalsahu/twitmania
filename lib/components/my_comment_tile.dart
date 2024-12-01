/*
  COMMENT TILE

  This is the comment tile widget which belongs below a post. It's similar to 
  the post tile widget, but let's make the comment slightly different to posts.

  ---------------------------------------------------------------------------------------------------------

  To use this widget, you need:

  - the comment
  - a function ( for when the user taps and wants to go to the user profile of this comment )

*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/models/comment.dart';
import 'package:twitmania/services/database/database_provider.dart';

import '../services/auth/auth_service.dart';

class MyCommentTile extends StatelessWidget {
  const MyCommentTile(
      {super.key, required this.comment, required this.onUserTap});
  final Comment comment;
  final void Function()? onUserTap;

  void _showOptions(BuildContext context) {
    // check if this post is owned by the user or not
    String currentUid = AuthService().getCurrentUserId();
    final bool isOwnComment = comment.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                // THIS COMMENT BELONGS TO USER
                if (isOwnComment)
                  // delete comment button
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () async {
                      Navigator.of(context).pop();

                      await Provider.of<DatabaseProvider>(context,
                              listen: false)
                          .deleteComment(
                        comment.id,
                        comment.postId,
                      );
                    },
                  )
                // THIS COMMENT DOESN'T BELONG TO USER
                else ...[
                  // report
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Report'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),

                  // block
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('Block user'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],

                // cancel button
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () {},
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: onUserTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                // name
                Text(
                  comment.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                // username
                Text(
                  '@${comment.username}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Expanded(child: Container()),
                // button -> more options: delete
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: Icon(
                    Icons.more_horiz,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            // message
            Text(
              comment.message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

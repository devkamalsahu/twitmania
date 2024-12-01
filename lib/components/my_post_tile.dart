/*
  POST TILE

  All posts will be displayed using this post tile widget.
  ------------------------------------------------------------------------------------------------

  To use this widget, you need:

  - the post
  - a function for onPostTap ( go to the individual post to see it's comments )
  - a function for onUserTap ( go to user's profile page )
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twitmania/components/my_input_alert_box.dart';
import 'package:twitmania/models/post.dart';
import 'package:twitmania/services/auth/auth_service.dart';
import 'package:twitmania/services/database/database_provider.dart';

import '../helper/time_formatter.dart';

class MyPostTile extends StatefulWidget {
  const MyPostTile({
    super.key,
    required this.post,
    required this.onUserTap,
    required this.onPostTap,
  });
  final Post post;
  final void Function()? onUserTap;
  final void Function()? onPostTap;

  @override
  State<MyPostTile> createState() => _MyPostTileState();
}

class _MyPostTileState extends State<MyPostTile> {
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  late final listeningProvider = Provider.of<DatabaseProvider>(context);

  // on startup
  @override
  void initState() {
    super.initState();

    // load comments for this post
    _loadComments();
  }

  /*
    LIKES
  */

  // user tapped like or unlike
  void _toggleLikePost() async {
    try {
      await databaseProvider.toggleLike(widget.post.id);
    } catch (e) {
      print(e);
    }
  }

  /*
    SHOW OPTIONS

    Case 1: This post belongs to current user
    - Delete 
    - Cancel

    Case 2: This post does not belong to current user

  */

  // show option for post
  void _showOptions() {
    // check if this post is owned by the user or not
    String currentUid = AuthService().getCurrentUserId();
    final bool isOwnPost = widget.post.uid == currentUid;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Wrap(
              children: [
                // THIS POST BELONGS TO USER
                if (isOwnPost)
                  // delete messag button
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete'),
                    onTap: () async {
                      Navigator.of(context).pop();

                      await databaseProvider.deletePost(widget.post.id);
                    },
                  )
                // THIS POST DOESN'T BELONG TO USER
                else ...[
                  // report
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Report'),
                    onTap: () {
                      Navigator.of(context).pop();

                      // handle report actions
                      _reportPostConfirmationBox();
                    },
                  ),

                  // block
                  ListTile(
                    leading: const Icon(Icons.block),
                    title: const Text('Block user'),
                    onTap: () {
                      Navigator.of(context).pop();

                      // handle block action
                      _blockUserConfirmation();
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

  void _reportPostConfirmationBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Message'),
        content: const Text(
          'Are you sure you want to report this message?',
        ),
        actions: [
          // cancel button
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),

          // Report button
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await databaseProvider.reportUser(
                    widget.post.id, widget.post.uid);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message reported!'),
                  ),
                );
              },
              child: const Text('Report'))
        ],
      ),
    );
  }

  // block user confirmation
  void _blockUserConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block User'),
        content: const Text(
          'Are you sure you want to block this user?',
        ),
        actions: [
          // cancel button
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel')),

          // Report button
          TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                await databaseProvider.blockUser(widget.post.uid);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User blocked!'),
                  ),
                );
              },
              child: const Text('Block'))
        ],
      ),
    );
  }

/*
    COMMENTS
*/

  final _commentController = TextEditingController();

  // opne commment box -> user wants to type new comment
  void _openNewCommentBox() {
    showDialog(
      context: context,
      builder: (context) => MyInputAlertBox(
        textController: _commentController,
        hintText: 'Type a comment',
        onPressed: () async {
          // add post in db
          await _addComment();
        },
        onPressedText: 'Post',
      ),
    );
  }

  // user typped post to add comment
  Future<void> _addComment() async {
    // does nothing if theres nothing in the textfield
    if (_commentController.text.trim().isEmpty) return;

    // attempt to post comment
    try {
      await databaseProvider.addComment(
          widget.post.id, _commentController.text.trim());
    } catch (e) {
      print(e);
    }
  }

  // load comments
  Future<void> _loadComments() async {
    await databaseProvider.loadComments(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    // does the current user like this post
    bool likedByCurrentUser =
        listeningProvider.isPostLikedByCurrentUser(widget.post.id);

    // listen to like count
    int likeCount = listeningProvider.getLikeCount(widget.post.id);

    // listen to comment count
    int commentCount = listeningProvider.getComments(widget.post.id).length;

    return GestureDetector(
      onTap: widget.onPostTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: GestureDetector(
          onTap: widget.onUserTap,
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
                    widget.post.name,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  // username
                  Text(
                    '@' + widget.post.username,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Expanded(child: Container()),
                  // button -> more options: delete
                  GestureDetector(
                    onTap: _showOptions,
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
                widget.post.message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 20),
              // buttons -> like + comments
              Row(
                children: [
                  // LIKE SECTION
                  SizedBox(
                    width: 60,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleLikePost,
                          child: likedByCurrentUser
                              ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.favorite_border,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                        const SizedBox(width: 5),
                        // like Count
                        Text(
                          likeCount != 0 ? likeCount.toString() : '',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  // COMMENT SECTION
                  Row(
                    children: [
                      // comment button
                      GestureDetector(
                        onTap: _openNewCommentBox,
                        child: Icon(
                          Icons.comment,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      // comment count
                      Text(
                        commentCount != 0 ? commentCount.toString() : '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // timestamp
                  Text(
                    formatTimestamp(widget.post.timestamp),
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
